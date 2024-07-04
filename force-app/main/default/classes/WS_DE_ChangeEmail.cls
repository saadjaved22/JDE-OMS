@RestResource(urlMapping='/ChangeAccountEmail/*')
global without sharing class WS_DE_ChangeEmail {
  @HttpPatch
  global static String changeAccountEmail() {
    RestRequest request = RestContext.request;
    String accountId = request.requestURI.substring(
      request.requestURI.lastIndexOf('/') + 1
    );
    // System.debug('accountId '+accountId );

    String currentEmail;
    String newEmail;

    Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
      request.requestbody.tostring()
    );
    currentEmail = String.valueOf(params.get('currentEmail'));
    newEmail = String.valueOf(params.get('newEmail'));
    String newEmailExtId = newEmail + Label.Country + Label.Brand;
    List<Account> accList;
    // System.debug('currentEmail '+ currentEmail);
    // System.debug('newEmail '+newEmail);
    if (Test.isRunningTest()) {
      accList = [
        SELECT Id, FirstName, LastName, personEmail, New_Email__c, ContactID__pc
        FROM Account
        LIMIT 1
      ];
    } else {
      accList = [
        SELECT
          Id,
          FirstName,
          LastName,
          personEmail,
          New_Email__c,
          New_Email_Request_Datetime__c,
          ContactID__pc
        FROM Account
        WHERE Id = :accountId AND IsCustomerPortal = TRUE
        LIMIT 1
      ];
    }
    List<Account> accListNewEmail = [
      SELECT
        Id,
        FirstName,
        LastName,
        personEmail,
        New_Email__c,
        New_Email_Request_Datetime__c
      FROM Account
      WHERE External_Id__c = :newEmailExtId AND IsCustomerPortal = TRUE
    ];
    // System.debug('account List \n'+accList);

    if (accList.size() > 0) {
      if (
        !ConsumerAttributes.validateEmail(newEmail) ||
        accListNewEmail.size() > 0
      ) {
        RestContext.response.statusCode = 400;
        return Label.DEInvalidEmailAddress;
      }
      if (currentEmail == accList[0].personEmail && currentEmail != newEmail) {
        try {
          accList[0].New_Email__c = newEmail;
          accList[0].New_Email_Request_Datetime__c = Datetime.now();

          Blob targetBlob = Blob.valueOf(
            String.valueOfGmt(accList[0].New_Email_Request_Datetime__c)
          );
          Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
          String hashBase64SHA1 = EncodingUtil.base64encode(hash);
          accList[0].New_Email_Confirm_URL__c =
            Label.Community_DE_BaseURL +
            '/s/confirmemailchange?u=' +
            EncodingUtil.URLENCODE(accList[0].personEmail, 'UTF-8') +
            '&s=' +
            EncodingUtil.URLENCODE(hashBase64SHA1, 'UTF-8');

          update accList;

          sendEmails(accList[0]);

          RestContext.response.statusCode = 200;
          return 'Success';
        } catch (Exception e) {
          RestContext.response.statusCode = 500;
          return e.getMessage();
        }
      } else {
        RestContext.response.statusCode = 400;
        return 'Bad request';
      }
    }
    RestContext.response.statusCode = 404;
    return 'Not found';
  }

  private static void sendEmails(Account acc) {
    sendMail(acc, acc.personEmail, Label.DE_Change_Email_Old_Template_ID);
    sendMail(acc, acc.New_Email__c);
  }

  // send email to the old email owner using classic email template & saving the email as activity
  private static void sendMail(
    Account acc,
    String toAddress,
    String templateId
  ) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new List<String>{ toAddress };

    mail.setToAddresses(toAddresses);
    mail.setReplyTo('spaarprogramma@douwe-egberts.com');
    mail.setSenderDisplayName('D.E Spaarprogramma');
    // mail.setSubject('D.E Spaarprogramma: e-mailverzoek wijzigen');
    mail.setBccSender(false);
    mail.setUseSignature(false);
    mail.setSaveAsActivity(true);

    mail.setTargetObjectId(acc.ContactID__pc);
    mail.setWhatId(acc.Id);
    mail.setTemplateId(templateId);

    Messaging.SendEmailResult[] results = Messaging.sendEmail(
      new List<Messaging.SingleEmailMessage>{ mail },
      true
    );
  }

  // overloading the method
  // to send  to the new Email owner without using classic email template & saving the activity manually without using "mail.setSaveAsActivity(true)"
  private static void sendMail(Account acc, String toAddress) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new List<String>{ toAddress };

    mail.setToAddresses(toAddresses);
    // mail.setCcAddresses(ccAddresses);
    mail.setReplyTo('spaarprogramma@douwe-egberts.com');
    mail.setSenderDisplayName('D.E Spaarprogramma');
    mail.setSubject('D.E Spaarprogramma: e-mailverzoek wijzigen');
    mail.setBccSender(false);
    mail.setUseSignature(false);

    String htmlBody =
      '<table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="bodyTable">' +
      '<tr>' +
      '<td align="center" valign="top">' +
      '<table border="0" cellpadding="20" cellspacing="0" width="600" id="emailContainer">' +
      '<tr>' +
      '<td align="center" valign="top">' +
      '<table border="0" cellpadding="20" cellspacing="0" width="100%" id="emailHeader">' +
      '<tr>' +
      '<td align="center" valign="top">' +
      '<img src="https://mijn.de.nl/resource/1634043391000/DELOGOFORLOGINFORM"width="auto" />' +
      '</td>' +
      '</tr>' +
      '</table>' +
      '</td>' +
      '</tr>' +
      '<tr>' +
      '<td align="left" valign="top" border="0" cellpadding="0" cellspacing="0" width="100%" style="padding:0px">' +
      'Beste  <b>' +
      acc.FirstName +
      ',</b> <br><br>' +
      'Wij hebben het verzoek ontvangen om het e-mailadres van je Mijn D.E account te wijzigen.<br> <br>' +
      'Vorig e-mailadres: ' +
      acc.personEmail +
      '<br>' +
      'Nieuw e-mailadres: ' +
      acc.New_Email__c +
      '<br>' +
      '<br> Is dit correct? <a href="' +
      acc.New_Email_Confirm_URL__c +
      '">Klik dan hier</a> ' +
      ' om de wijziging te voltooien. <br>' +
      'Let op: deze link verloopt over 72 uur.' +
      '<br><br>Hartelijke groet,<br>' +
      '<br>het Douwe Egberts team <br><br>' +
      '</td>' +
      '</tr>' +
      '<tr>' +
      '<td align="center" style="font-size:0px;padding:10px 25px;word-break:break-word;"bgcolor="#000000">' +
      '<div style="font-family:Arial;font-size:12px;line-height:16px;text-align:center;color:grey;">' +
      '<a target="_blank" style="color: #8e8e8e; text-decoration: none;"' +
      'href="https://mijn.de.nl">Inloggen bij Mijn D.E</a>&nbsp;&nbsp;|&nbsp;&nbsp; ' +
      '<a target="_blank" style="color: #8e8e8e; text-decoration: none;"' +
      'href="https://www.de.nl/spaarprogramma">D.E Spaarprogramma</a>&nbsp;&nbsp;|&nbsp;&nbsp; <a>' +
      '<a target="_blank" style="color: #8e8e8e; text-decoration: none;" href="https://www.de.nl">Naar DE.nl</a>' +
      '</div>' +
      '</td>' +
      '</tr>' +
      '<tr>' +
      '<td bgcolor="#f2f2f2">' +
      '<div style="background:transparent;background-color:transparent;Margin:0px auto;max-width:600px;">' +
      '<table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation"' +
      'style="background:transparent;background-color:transparent;width:100%;">' +
      '<tbody>' +
      '<tr>' +
      '<td style="direction:ltr;font-size:0px;padding:0;text-align:center;vertical-align:top;">' +
      '<div class="mj-column-per-100 outlook-group-fix"' +
      'style="font-size:13px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;">' +
      '<table border="0" cellpadding="0" cellspacing="0"' +
      'role="presentation" style="vertical-align:top;" width="100%">' +
      '<tr>' +
      '<td align="center"' +
      'style="font-size:0px;padding:10px 25px;word-break:break-word;">' +
      '<div style="font-family:Arial;font-size:11px;line-height:16px;text-align:center;color:#747474;">' +
      'Je ontvangt dit servicebericht omdat je je hebt ' +
      'aangemeld voor het D.E Spaarprogramma. <br />' +
      'Het is niet mogelijk om je voor dit type berichten ' +
      'af te melden zolang je account actief ' +
      'is.<br /><br />' +
      '<strong>Contact</strong><br /> ' +
      'Heb je nog vragen naar aanleiding van dit bericht? ' +
      '<a target="_blank" style="color: #747474;" href="https://www.de.nl/consumentenservice/">Klik dan hier</a>' +
      ' om contact op te nemen met Consumentenservice.' +
      '<br /><br /> <strong>Wil je je account ' +
      'verwijderen?</strong><br /> Je account bij Mijn ' +
      'D.E opzeggen kan door in te loggen via <a target="_blank"' +
      'style="color: #747474; text-decoration: underline"' +
      'href="https://mijn.de.nl/">deze link</a>.' +
      '<br /><br /> <strong>Adres:</strong><br />' +
      'Jacobs Douwe Egberts NL B.V.<br />' +
      'Vleutensevaart 35, 3532AD, Utrecht, NL' +
      '</div>' +
      '</td>' +
      '</tr>' +
      '</table>' +
      '</div>' +
      '</td>' +
      '</tr>' +
      '</tbody>' +
      '</table>' +
      '</div>' +
      '</td>' +
      '</tr>' +
      '</table>' +
      '</td>' +
      '</tr>' +
      '</table>';
    mail.setHtmlBody(htmlBody);
    Messaging.SendEmailResult[] results = Messaging.sendEmail(
      new List<Messaging.SingleEmailMessage>{ mail },
      true
    );

    if (results[0].success) {
      // The email was sent successfully
      EmailMessage createWhatEmail = new EmailMessage(
        Subject = 'D.E Spaarprogramma: e-mailverzoek wijzigen',
        Status = '3',
        ToAddress = toAddress,
        FromAddress = 'spaarprogramma@douwe-egberts.com',
        FromName = UserInfo.getFirstName() + ' - ' + UserInfo.getLastName(),
        HtmlBody = htmlBody,
        Incoming = false,
        MessageDate = DateTime.now(),
        RelatedToId = acc.Id
      );
      insert createWhatEmail;
    }
  }
}
