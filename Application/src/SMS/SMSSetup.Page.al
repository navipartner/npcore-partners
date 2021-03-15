page 6014404 "NPR SMS Setup"
{
    Caption = 'SMS Setup';
    PageType = Card;
    SourceTable = "NPR SMS Setup";
    PromotedActionCategories = 'New,Tasks,Reports,Display';
    RefreshOnActivate = true;
    UsageCategory = Administration;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = ' General';
                field("Message Provider"; Rec."SMS Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS Provider field';
                    trigger OnValidate()
                    begin
                        SetVisible()
                    end;
                }
                field("Discard Msg. Older Than [Hrs]"; Rec."Discard Msg. Older Than [Hrs]")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discard Msg. Older Than [Hrs] field';
                }
                field("Job Queue Category Code"; Rec."Job Queue Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job Queue Category Code field';
                }
                field("Auto Send Attempts"; Rec."Auto Send Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Send Attempts field';
                }
            }
            group(Navipartner)
            {
                Caption = 'NaviPartner';
                Visible = NaviVisisble;
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Default Sender No."; Rec."Default Sender No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Sender No. field';
                }
                field("Domestic Phone Prefix"; Rec."Domestic Phone Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Domestic Phone Prefix field';
                }
            }
            group(Endpoint)
            {
                Caption = 'Endpoint';
                Visible = EndpointVisible;
                field("SMS Endpoint"; Rec."SMS Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS Endpoint field';
                }
                field("SMS-Address Postfix"; Rec."SMS-Address Postfix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS-Address Postfix field';
                }
                field("Local E-Mail Address"; Rec."Local E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Local E-Mail Address field';
                }
                field("Local SMTP Pickup Library"; Rec."Local SMTP Pickup Library")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Local SMTP Pickup Library field';
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
                ApplicationArea = All;
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
                ApplicationArea = All; 
                RunObject = page "NPR SMS Log"; 

            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
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