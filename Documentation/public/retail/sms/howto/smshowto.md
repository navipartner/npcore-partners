# Configure the SMS Setup

This topic describes the process of configuring the SMS Setup. As soon as the necessary setup is completed, the SMS functionality can be used.


1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **SMS Setup** and open the related link.      
   You can use the [reference guide](../reference/sms_module_reference.md) to learn what the purpose of each field in the **SMS Setup Card** is. 
2. In the **General** section make a selection of the **SMS Provider** in the adequate field.       
   The content of the following tab will be different depending on your selection in the **SMS Provider** field.
3. Specify the time until the message gets discarded in the **Discard Msg. Older Than [Hrs]** field.
4. In **Job Queue Category Code** select the **Job Queue** that will be used for processing queued SMS messages.     

   > [!Note]
   > Job queue enables users to schedule and run specific reports or codeunits. In this specific case, there's a codeunit which runs a task for sending SMS in a batch in regular, predefined intervals. The task is recurring, so any new SMS is sent automatically via the job queue. The job queue is set in the **Job Queue Entries** administrative section using the *6014469 - NPR Send SMS Job Handler* codeunit.

5. In **Auto Send Attempts** specify the number of attempts before message gets discarded.
6. Set up the provider.

### SMS Provider Setup

If you choose **NaviPartner** as **SMS Provider**, complete the following steps:

   1. In **Customer No.** define the NaviPartner customer number that will be used for billing.
   2. In **Default Sender No.** provide number that will be used for sending.
   3. In **Domestic Phone Prefix** provide the calling code that will be used if it wasn't previously specified in the customer's phone number.

If you choose **Endpoint** as **SMS Provider**, complete the following steps:

   1. In the **SMS Endpoint** field define the alternative SMS provider that will be used instead of NaviPartner. If the necessary endpoint isn't shown, a new one can be created in the **Nc Endpoints** page.
   2. In the **SMS-Address Postfix** field, provide the value that will be added to the recipient's phone number.
   3. In **Local E-Mail Address**, provide the email that will be added to the **Sender** field.
   4. Specify the name of the created task in the **Local SMTP 'Pickup' Library** field.
   