page 6014404 "NPR SMS Setup"
{
    Caption = 'SMS Setup';
    PageType = Card;
    SourceTable = "NPR SMS Setup";
    PromotedActionCategories = 'New,Tasks,Reports,Display';
    RefreshOnActivate = true;
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'product/sms/howto/smshowto.html';
    DeleteAllowed = false;
    InsertAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = ' General';
                field("Message Provider"; Rec."SMS Provider")
                {

                    ToolTip = 'Specifies the value of the SMS Provider field. Select "Navipartner" if you want to use Navipartner SMS provider and "Endpoint" if you want to use external SMS provider.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        SetVisible()
                    end;
                }
                field("Discard Msg. Older Than [Hrs]"; Rec."Discard Msg. Older Than [Hrs]")
                {

                    ToolTip = 'Specifies the value of the Discard Msg. Older Than [Hrs] field. If message is not sent before Discard time, it will be marked as discarded and it wont''t be sent.';
                    ApplicationArea = NPRRetail;
                }
                field("Job Queue Category Code"; Rec."Job Queue Category Code")
                {

                    ToolTip = 'Specifies the value of the Job Queue Category Code field. This is used to create a Job Queue which will run every minute and send SMSs that are scheduled.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Attempts"; Rec."Auto Send Attempts")
                {

                    ToolTip = 'Specifies the value of the Auto Send Attempts field. Use this field to define in how many attempts the system will try to send the SMS.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Navipartner)
            {
                Caption = 'NaviPartner';
                Visible = NaviVisisble;
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'This field is used for billing the usage of SMS service. Enter your customer number at NaviPartner in this field.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Sender No."; Rec."Default Sender No.")
                {

                    ToolTip = 'Specifies the default Sender No. that will be used for sending SMS. This number will be visible in the SMS.';
                    ApplicationArea = NPRRetail;
                }
                field("Domestic Phone Prefix"; Rec."Domestic Phone Prefix")
                {

                    ToolTip = 'Specifies the value of the Domestic Phone Prefix field. The prefix entered in this field will be added to phone numbers which don''t have prefix.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Endpoint)
            {
                Caption = 'Endpoint';
                Visible = EndpointVisible;
                field("SMS Endpoint"; Rec."SMS Endpoint")
                {

                    ToolTip = 'Specifies the value of the SMS Endpoint field. If you use Endpoint instead of Navipartner as SMS Provider, you have to specify which Endpoint you want to use.';
                    ApplicationArea = NPRRetail;
                }
                field("SMS-Address Postfix"; Rec."SMS-Address Postfix")
                {

                    ToolTip = 'Specifies the value of the SMS-Address Postfix field. SMS-Address Postfix is added to Phone Number, depending on Endpoint you use as SMS Provider.';
                    ApplicationArea = NPRRetail;
                }
                field("Local E-Mail Address"; Rec."Local E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the Local E-Mail Address field. Local E-Mail Address is added to the Sender field, depending on the Endpoint you use as SMS Provider.';
                    ApplicationArea = NPRRetail;
                }
                field("Local SMTP Pickup Library"; Rec."Local SMTP Pickup Library")
                {

                    ToolTip = 'Specifies the value of the Local SMTP Pickup Library field. This field is used to define name of created Task for sending SMS to selected Endpoint.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RunJob)
            {
                Caption = 'Send SMS Job';
                ToolTip = 'Runs the procedure which will send all queued SMS.';
                Image = ExecuteAndPostBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MessageJOBHandler: Codeunit "NPR Send SMS Job Handler";
                begin
                    MessageJOBHandler.Run();
                end;
            }
            action(SMSLog)
            {
                Caption = 'SMS Log Page';
                ToolTip = 'Run SMS log Page where you can see all SMS entries.';
                Image = ListPage;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                RunObject = page "NPR SMS Log";
                ApplicationArea = NPRRetail;

            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        SetVisible();
    end;

    local procedure SetVisible()
    begin
        NaviVisisble := Rec."SMS Provider" = Rec."SMS Provider"::NaviPartner;
        EndpointVisible := Rec."SMS Provider" = Rec."SMS Provider"::Endpoint
    end;

    var
        NaviVisisble: Boolean;
        EndpointVisible: Boolean;
}