class MpgController < ApplicationController
    require 'digest'
    skip_before_action :verify_authenticity_token, only: [:return, :notif, :create_order]

    def index
        
    end

    def create_order
      
      merchantID = 'MS15746696' #填入你的商店號碼
      version = '1.5'
      respondType = 'JSON'
      timeStamp = Time.now.to_i.to_s
      merchantOrderNo = Time.now.to_i.to_s
      itemDesc = Project.find_by({id: params[:project_id]}).name + " 募資"
      hashKey = 'EHb1JZZqWyYrRrafyoJSh00jkhTtKqKt' #填入你的key
      hashIV = 'XQVawXqs3ClPQoPX' #填入你的IV

      # 檢查使用者是否登入
      unless user_signed_in?
        flash[:notice] = "您沒有登入，無法進行募資動作。"
        return redirect_to "/"
      end


      @project_id = params[:project_id]
      @order_type = params[:order_type]
      @quantity = params[:quantity]

      json = {
        projects_id: @project_id,
        users_id: current_user.id,
        order_no: merchantOrderNo
      }
      order_create_stmt = Order.not_pay_yet.create(json)

      unless order_create_stmt.valid?
        flash[:notice] = "資料庫操作失敗，請稍候嘗試。"
        return redirect_to "/project#{@project_id}"
      end

      orderID = order_create_stmt.id

      
      if @order_type == "advanced"
        amt = @quantity.to_i * 500
        OrderDetail.advanced.create({quantity: @quantity.to_i, total: @quantity.to_i*500, orders_id: orderID})
      elsif @order_type == "pure" 
        OrderDetail.pure.create({quantity: @quantity.to_i, total: @quantity.to_i*100, orders_id: orderID})
        amt = @quantity.to_i * 100
      elsif @order_type == "ordinary"
        OrderDetail.ordinary.create({quantity: @quantity.to_i, total: @quantity.to_i*100, orders_id: orderID})
        amt = @quantity.to_i * 100
      end

      
  
      data = "MerchantID=#{merchantID}&RespondType=#{respondType}&TimeStamp=#{timeStamp}&Version=#{version}&MerchantOrderNo=#{merchantOrderNo}&Amt=#{amt}&ItemDesc=#{itemDesc}&TradeLimit=120"
      puts data
      data = addpadding(data)
      aes = encrypt_data(data, hashKey, hashIV, 'AES-256-CBC')
      checkValue = "HashKey=#{hashKey}&#{aes}&HashIV=#{hashIV}"
  
      @merchantID = merchantID
      @tradeInfo = aes
      @tradeSha = Digest::SHA256.hexdigest(checkValue).upcase
      @version = version
    end
  
    def notify
      hashKey = 'EHb1JZZqWyYrRrafyoJSh00jkhTtKqKt'
      hashIV = 'XQVawXqs3ClPQoPX'
      if params["Status"] == "SUCCESS"
        tradeInfo = params["TradeInfo"]
        tradeSha = params["TradeSha"]
  
        checkValue = "HashKey=#{hashKey}&#{tradeInfo}&HashIV=#{hashIV}"
        if tradeSha == Digest::SHA256.hexdigest(checkValue).upcase
          rawTradeInfo = decrypt_data(tradeInfo, hashKey, hashIV, 'AES-256-CBC')
          result = JSON.parse(rawTradeInfo)
          # 得到 MerchantOrderNo
          __order_no = result.MerchantOrderNo
          # 設置 已付款
          __is_payment_stmt = Order.find_by({order_no: __order_no}).update({is_payment: 1})
          
          unless __is_payment_stmt
            Logger.new("#{Rails.root}/notify.log").try("info", "__is_payment_stmt")
            # send email to website servers
          end

          # 設置 支付方式 （ PaymentType )
          __PaymentType = result.PaymentType
          
          __set_payment_type = Order.find_by({order_no: __order_no}).order_details.update({payment_type: __PaymentType})

          unless __set_payment_type
            Logger.new("#{Rails.root}/notify.log").try("info", "__set_payment_type")
            # send email to website servers
          end

          # 設置 PayTime
          __PayTime = result.PayTime
          __set_paytime_stmt = Order.find_by({order_no: __order_no}).update({pay_time: __PayTime})

          unless __set_paytime_stmt
            Logger.new("#{Rails.root}/notify.log").try("info", "__set_paytime_stmt")
            # send email to website servers
          end
          
        end
      end
  
      respond_to do |format|
        format.json {render json: {result: "success"}}
      end
    end
  
    def return
      Logger.new("#{Rails.root}/return.log").try("info", params)
  
      hashKey = 'tHxTbWao53bkYhthsvbCl9hmM1GTamAc'
      hashIV = 'LBcCZ00KKisIWR77'
  
      if params["Status"] == "SUCCESS"
  
        tradeInfo = params["TradeInfo"]
        tradeSha = params["TradeSha"]
  
        checkValue = "HashKey=#{hashKey}&#{tradeInfo}&HashIV=#{hashIV}"
        if tradeSha == Digest::SHA256.hexdigest(checkValue).upcase
          rawTradeInfo = decrypt_data(tradeInfo, hashKey, hashIV, 'AES-256-CBC')
          result = JSON.parse(rawTradeInfo)
          Logger.new("#{Rails.root}/return.log").try("info", result)
        end
      end
  
      redirect_to "/"
    end
  
    def customer
      hashKey = 'tHxTbWao53bkYhthsvbCl9hmM1GTamAc'
      hashIV = 'LBcCZ00KKisIWR77'
  
      if params["Status"] == "SUCCESS"
  
        tradeInfo = params["TradeInfo"]
        tradeSha = params["TradeSha"]
  
        checkValue = "HashKey=#{hashKey}&#{tradeInfo}&HashIV=#{hashIV}"
        if tradeSha == Digest::SHA256.hexdigest(checkValue).upcase
          rawTradeInfo = decrypt_data(tradeInfo, hashKey, hashIV, 'AES-256-CBC')
          result = JSON.parse(rawTradeInfo)
          Logger.new("#{Rails.root}/customer.log").try("info", result)
        end
      end
  
      redirect_to "/"
    end
  
    private
  
    def addpadding(data, blocksize = 32)
      len = data.length
      pad = blocksize - ( len % blocksize)
      data += pad.chr * pad
      return data
    end
  
    def encrypt_data(data, key, iv, cipher_type)
      cipher = OpenSSL::Cipher.new(cipher_type)
      cipher.encrypt
      cipher.key = key
      cipher.iv = iv
      encrypted = cipher.update(data) + cipher.final
      return encrypted.unpack("H*")[0].upcase
    end
  
    def removedPadding(data)
      blocksize = 32
      loop do
        lastHex = data.last.bytes.first
        break if lastHex >= blocksize
        data = data[0...-lastHex]
      end
      return data
    end
  
    def decrypt_data(data, key, iv, cipher_type)
      cipher = OpenSSL::Cipher.new(cipher_type)
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv
      packedData = [data.downcase].pack('H*')
      data = removedPadding(cipher.update(packedData))
      begin
        return data + cipher.final
      rescue
        return data
      end
    end
end