page 6184819 "NPR FR POS EOD Profile Step"
{
    Caption = 'FR POS End of Day Profile Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR POS End of Day Profile";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(EndOfDay)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the unique code of the profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a short description of what the profile is used for.';
                    ApplicationArea = NPRRetail;
                }
                field("End of Day Frequency"; Rec."End of Day Frequency")
                {
                    ToolTip = 'Specifies how often the end of day process is required.';
                    ApplicationArea = NPRRetail;
                }
                field("End of Day Type"; Rec."End of Day Type")
                {
                    ToolTip = 'Specifies whether the end-of-day process is performed for each POS unit, or if one POS unit is in charge of all counitng and cash collection.';
                    ApplicationArea = NPRRetail;
                }
                field("Master POS Unit No."; Rec."Master POS Unit No.")
                {
                    ToolTip = 'Specifies the number of the POS unit in charge of counting and cash collection.';
                    ApplicationArea = NPRRetail;
                }
                field("Z-Report UI"; Rec."Z-Report UI")
                {
                    ToolTip = 'Specifies what is displayed when the button for the POS balancing action is used.';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report UI"; Rec."X-Report UI")
                {
                    ToolTip = 'Specifies how many details related to the status of the POS unit during the workshift are displayed on the POS. ';
                    ApplicationArea = NPRRetail;
                }
                field("Close Workshift UI"; Rec."Close Workshift UI")
                {
                    ToolTip = 'Specifies whether printout is performed on closing the work shift. Currently, it''s not in use as when the balancing is completed, the work shift is automatically closed, and followed by a printout.';
                    ApplicationArea = NPRRetail;
                }
                field("Force Blind Counting"; Rec."Force Blind Counting")
                {
                    ToolTip = 'Display the expected ledger balance of the cash on the counting screen. When this function is activated, the expected ledger balance of the counted cash isn''t visible.';
                    ApplicationArea = NPRRetail;
                }
                field("Hide Turnover Section"; Rec."Hide Turnover Section")
                {
                    ToolTip = 'Specifies the value of the Hide Turnover Section field';
                    ApplicationArea = NPRRetail;
                }
                field("SMS Profile"; Rec."SMS Profile")
                {
                    ToolTip = 'Set up an SMS profile to send an SMS to the supervisor with the result of the counting.';
                    ApplicationArea = NPRRetail;
                }
                field("Z-Report Number Series"; Rec."Z-Report Number Series")
                {
                    ToolTip = 'Specifies the number series used for creating the Document No. in the POS entry for entries created from running the Z report.';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report Number Series"; Rec."X-Report Number Series")
                {
                    ToolTip = 'Specifies the number series used for creating the Document No. in the POS entry for entries created from running the X report.';
                    ApplicationArea = NPRRetail;
                }
                field("Show Zero Amount Lines"; Rec."Show Zero Amount Lines")
                {
                    ToolTip = 'Display all currencies when counting is performed, even if they amount to zero. This function needs to be used with discretion, as it might result in confusion.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    var
        NPRPOSEndofDayProfile: Record "NPR POS End of Day Profile";
    begin
        if NPRPOSEndofDayProfile.FindSet() then
            repeat
                Rec.TransferFields(NPRPOSEndofDayProfile);
                if not Rec.Insert() then
                    Rec.Modify();
            until NPRPOSEndofDayProfile.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreatePOSEODProfieData()
    var
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
    begin
        if Rec.FindSet() then
            repeat
                POSEndofDayProfile.TransferFields(Rec);
                if not POSEndofDayProfile.Insert() then
                    POSEndofDayProfile.Modify();
            until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        Rec.SetRange("End of Day Type", Rec."End of Day Type"::INDIVIDUAL);
        Rec.SetRange("End of Day Frequency", Rec."End of Day Frequency"::DAILY);

        exit(Rec.FindFirst());
    end;

}
