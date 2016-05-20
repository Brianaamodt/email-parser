require 'net/imap'
require 'rest_client'
require 'mail'
require 'base64'
load 'mailboxHelper.rb'

class String
    def string_between_markers marker1, marker2
        self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    end
end

def handleMessage(parsedMessage)
    # Either establish a single url or utelise the URL path list in mailboxHelper.rb
    @urlList.each do |url|
        puts url
        # sends parsed email data to urls set up by user
        response = RestClient.post(URI::encode(url), parsedMessage.to_json, content_type: 'application/json')
        puts "HM: #{parsedMessage.class}"
    end
end

while true
    @emailServiceProviders.each do |esp|
        begin
            imap = Net::IMAP.new(esp.address, esp.port, esp.encryption)
            imap.login(esp.user_email, esp.password)
            imap.select(esp.getMailbox)
            msgs = imap.search(['ALL'])
            emailHeaders = Hash.new
            msgs.each do |id|
                puts id
                body = imap.fetch(id, 'RFC822')[0].attr['RFC822']
                mail = Mail.new(body)
                data = imap.fetch(id, 'ENVELOPE')[0].attr['ENVELOPE']
                bodyArray = imap.fetch(id, "RFC822.TEXT")[0].attr['RFC822.TEXT'].split('Content-Type: text/html')
                if (esp.address === "imap.gmail.com")
                    emailHeaders["Body"] = bodyArray[0].string_between_markers("charset=UTF-8" ,"--").to_s.gsub("\r\n\r\n", " ").gsub("\r\n", " ")
                elsif (esp.address === "imap-mail.outlook.com")
                    emailHeaders["Body"] = bodyArray[0].string_between_markers("Content-Transfer-Encoding: quoted-printable" ,"--")
                elsif (esp.address === "imap.mail.yahoo.com")
                    emailHeaders["Body"] = bodyArray[0].string_between_markers("Content-Transfer-Encoding: 7bit" ,"--").to_s.gsub("\r\n\r\n", " ").gsub("\r\n", " ")
                end
                if mail.attachments != nil
                    mail.attachments.each do |attachment|
                        emailHeaders["Attachment"] = Base64.encode64(attachment.body.decoded)
                        # file.open(Base64.decode64(emailHeaders["Attachment"]), wb)
                    end
                end
                if data.cc != nil
                    data.cc.each do |copiedAddress|
                        emailHeaders["Cc"] = copiedAddress.mailbox + '@' + copiedAddress.host
                    end
                end
                if data.bcc != nil
                    data.bcc.each do |copiedAddress|
                        emailHeaders["Bcc"] = copiedAddress.mailbox + '@' + copiedAddress.host
                    end
                end
                data.from.each do |copiedAddress|
                    emailHeaders["From"] = copiedAddress.mailbox + '@' + copiedAddress.host
                end
                data.to.each do |copiedAddress|
                    emailHeaders["To"] = copiedAddress.mailbox + '@' + copiedAddress.host
                end
                if data.subject != nil
                    emailHeaders["Subject"] = data.subject
                end
                handleMessage(emailHeaders)
                imap.copy(id, esp.sendToMailbox)
                imap.store(id, "+FLAGS", [:Deleted])
            end
            imap.expunge
            imap.logout
            imap.disconnect
        rescue
            next
        end
    end
    sleep 60
end
