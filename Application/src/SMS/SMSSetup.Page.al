page 6014404 "NPR SMS Setup"
{
    Caption = 'SMS Setup';
    PageType = Card;
    SourceTable = "NPR SMS Setup";
    PromotedActionCategories = 'New,Tasks,Reports,Display';
    RefreshOnActivate = true;
    UsageCategory = Administration;

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

                    ToolTip = 'Specifies the value of the SMS Provider field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        SetVisible()
                    end;
                }
                field("Discard Msg. Older Than [Hrs]"; Rec."Discard Msg. Older Than [Hrs]")
                {

                    ToolTip = 'Specifies the value of the Discard Msg. Older Than [Hrs] field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Queue Category Code"; Rec."Job Queue Category Code")
                {

                    ToolTip = 'Specifies the value of the Job Queue Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Attempts"; Rec."Auto Send Attempts")
                {

                    ToolTip = 'Specifies the value of the Auto Send Attempts field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Navipartner)
            {
                Caption = 'NaviPartner';
                Visible = NaviVisisble;
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Sender No."; Rec."Default Sender No.")
                {

                    ToolTip = 'Specifies the value of the Default Sender No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Domestic Phone Prefix"; Rec."Domestic Phone Prefix")
                {

                    ToolTip = 'Specifies the value of the Domestic Phone Prefix field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Endpoint)
            {
                Caption = 'Endpoint';
                Visible = EndpointVisible;
                field("SMS Endpoint"; Rec."SMS Endpoint")
                {

                    ToolTip = 'Specifies the value of the SMS Endpoint field';
                    ApplicationArea = NPRRetail;
                }
                field("SMS-Address Postfix"; Rec."SMS-Address Postfix")
                {

                    ToolTip = 'Specifies the value of the SMS-Address Postfix field';
                    ApplicationArea = NPRRetail;
                }
                field("Local E-Mail Address"; Rec."Local E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the Local E-Mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Local SMTP Pickup Library"; Rec."Local SMTP Pickup Library")
                {

                    ToolTip = 'Specifies the value of the Local SMTP Pickup Library field';
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
                ToolTip = 'Run send SMS Job';
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
                ToolTip = 'Run SMS log Page';
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