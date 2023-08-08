page 6014511 "NPR generic retail Headline"
{
    Extensible = False;
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
                Visible = false;
                field(GreetingText; GreetingText)
                {
                    Caption = 'Greetings headline';
                    Editable = false;
                    ToolTip = 'Greeting text.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(LearnMoreAndVersionNr)
            {
                field(LearnMore; NPRetailTxt)
                {
                    Caption = 'Learn more about NP Retail headline';
                    Editable = false;
                    ToolTip = 'Learn more about NP Retail.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        DrillDownURLTxt: Label 'https://www.navipartner.com', Locked = true;
                    begin
                        Hyperlink(DrillDownURLTxt)
                    end;
                }
                field(WhatIsNewText; WhatIsNewText)
                {
                    Caption = 'What''s new';
                    Editable = false;
                    ToolTip = 'What is new in NP Retail.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        DrillDownURLTxt: Label 'https://docs.navipartner.com/docs/retail/gettingstarted/release_notes/', Locked = true;
                    begin
                        Hyperlink(DrillDownURLTxt);
                    end;
                }
                field(NPRVersionNumber; NPRVersion)
                {
                    Caption = 'NPR Version';
                    Editable = false;
                    ToolTip = 'NPR Version';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        Regex: Codeunit "NPR RegEx";
    begin
        Regex.GetSingleMatchValue(LicenseInformation.GetRetailVersion(), RegexVersionPatternLbl, NPRRetailVersion);
        HeadlineManagement.GetUserGreetingText(GreetingText);
        NPRVersion := CopyStr(StrSubstNo(NPRVersionTxt, NPRRetailVersion), 1, MaxStrLen(NPRVersion));
    end;

    var
        HeadlineManagement: Codeunit "NPR NP Retail Headline Mgt.";
        GreetingText: Text;
        NPRetailTxt: Label 'Want to learn more about NP Retail?';
        LicenseInformation: Codeunit "NPR License Information";
        NPRVersionTxt: Label 'You are currently on version NP RETAIL %1', Comment = '%1 is the NP Retail version number';
        NPRVersion: Text[250];
        WhatIsNewText: Label 'What''s new?', Locked = true;
        NPRRetailVersion: Text;
        RegexVersionPatternLbl: Label '[\d.,]+', Locked = true;
}
