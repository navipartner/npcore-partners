page 6014511 "NPR generic retail Headline"
{
    Caption = 'Generic retail Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Greeting)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;
                field(GreetingText; GreetingText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Greetings headline';
                    Editable = false;
                    ToolTip = 'Greeting txt';
                }
            }
            group(LearnMoreAndVersionNr)
            {
                field(LearnMore; NPRetailTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Learn more about NP Retail headline';
                    Editable = false;
                    ToolTip = 'Learn more about NP Retail';

                    trigger OnDrillDown()
                    var
                        DrillDownURLTxt: Label 'https://www.navipartner.com', Locked = true;
                    begin
                        Hyperlink(DrillDownURLTxt)
                    end;


                }
                field(NPRVersionNumber; NPRVersion)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'NPR Version';
                    Editable = false;
                    ToolTip = 'NPR Version';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        ComputeDefaultFieldsVisibility();
        HeadlineManagement.GetUserGreetingText(GreetingText);
        NPRVersion := StrSubstNo(NPRVersionTxt, LicenseInformation.GetRetailVersion());
    end;

    var
        HeadlineManagement: Codeunit "NPR NP Retail Headline Mgt.";
        GreetingText: Text[250];
        NPRetailTxt: Label 'Want to learn more about NP Retail?';
        UserGreetingVisible: Boolean;
        LicenseInformation: Codeunit "NPR License Information";
        NPRVersionTxt: Label 'You are currently on version %1', Comment = '%1 is the NP Retail version number';
        NPRVersion: Text[250];

    local procedure ComputeDefaultFieldsVisibility()
    begin
        UserGreetingVisible := HeadlineManagement.ShouldUserGreetingBeVisible();
    end;
}