# Configure SMS Setup

This topic describes the process of configuring the SMS Setup. As soon as necessary setup is completed, SMS functionality can be used.

## SMS Setup Steps

1. Open **SMS Setup** page.
2. Fill necessary information in **General** section
   - Make a selection of the **SMS Provider** in the adequate field. Based on the selected option, the additional section will be displayed.
   - Specify the time in hours left until the message gets discarded in the **Discard Msg. Older Than [Hrs]** field.
   - In **Job Queue Category Code** select Job Queue that will be used for processing queued SMS messages.
   - In **Auto Send Attempts** specify the number of attempts before message gets discarded.
3. Set up the Provider

### SMS Provider Setup

If you choose **NaviPartner** as **SMS Provider**, complete the following steps:

   1. In **Customer No.** define NaviPartner Customer No. that will be used for billing.
   2. In **Default Sender No.** provide number that will be used for sending.
   3. In **Domestic Phone Prefix** provide calling code that will be used if it it not specified in phone number.

If you choose **Endpoint** as **SMS Provider**, complete the following steps:

   1. In the **SMS Endpoint** field define the alternative SMS provided that will be used instead of NaviPartner. If the necessary endpoint isn't shown, a new one can be created in the **Nc Endpoints** page.
   2. In the **SMS-Address Postfix** field, provide the value that will be added to the recipient's phone number.
   3. In **Local E-Mail Address**, provide the value that will be added to the **Sender** field.
   4. Specify the name of the created task in the **Local SMTP 'Pickup' Library** field.
   