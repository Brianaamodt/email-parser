@urlList = [
    'https://www.website1.com/',
    'https://www.website2.com/'
]

class MailboxProcess
    # Used to access Task
    attr_accessor :address, :port, :encryption
    # Used to connect to the mailbox
    attr_accessor :user_email, :password, :getMailbox, :sendToMailbox
    def initialize(args)
        @address = args[:address]
        @port= args[:port]
        @encryption= args[:encryption]
        @user_email = args[:user_email]
        @password = args[:password]
        @getMailbox = args[:getMailbox]
        @sendToMailbox = args[:sendToMailbox]
    end
end

# to add an additional
@emailServiceProviders = [
    MailboxProcess.new(
        address: "imap.gmail.com", port: 993, encryption: true, user_email: "email@gmail.com", password: "password", getMailbox: "INBOX", sendToMailbox: "otherBox"
    ),
    MailboxProcess.new(
        address: "imap-mail.outlook.com", port: 993, encryption: true, user_email: "email@msn.com", password: "password", getMailbox: "Inbox", sendToMailbox: "otherBox"
    ),
    MailboxProcess.new(
        address: "imap.mail.yahoo.com", port: 993, encryption: true, user_email: "email@yahoo.com", password: "password", getMailbox: "Inbox", sendToMailbox: "otherBox"
    )
]
