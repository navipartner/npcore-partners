page 6014681 "NPR POS Posting Profiles Step"
{
    Caption = 'POS Posting Profiles';
    PageType = ListPart;
    SourceTable = "NPR POS Posting Profile";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInPOSPOSPostingProfile(TempExistingPOSPostingProfiles, Rec.Code);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Max. POS Posting Diff. (LCY)"; Rec."Max. POS Posting Diff. (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                }
                field("POS Posting Diff. Account2"; Rec."POS Posting Diff. Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Differences Account field';
                }
                field("POS Sales Rounding Account"; Rec."POS Sales Rounding Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sales Rounding Account field';
                }
                field("POS Sales Amt. Rndng Precision"; Rec."POS Sales Amt. Rndng Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sales Amt. Rndng Precision field';
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Type field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        TempExistingPOSPostingProfiles: Record "NPR POS Posting Profile" temporary;

    procedure GetRec(var TempPOSPostingProfile: Record "NPR POS Posting Profile")
    begin
        TempPOSPostingProfile.Copy(Rec);
    end;

    procedure CreatePOSPOSPostingProfileData()
    var
        POSPOSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if Rec.FindSet() then
            repeat
                POSPOSPostingProfile := Rec;
                if not POSPOSPostingProfile.Insert() then
                    POSPOSPostingProfile.Modify();
            until Rec.Next() = 0;
    end;

    procedure POSPOSPostingProfileDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempPOSPostingProfile: Record "NPR POS Posting Profile")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        TempPOSPostingProfile.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSPostingProfile := Rec;
                TempPOSPostingProfile.Insert();
            until Rec.Next() = 0;

        TempPOSPostingProfile.Init();
        if POSPostingProfile.FindSet() then
            repeat
                TempPOSPostingProfile.TransferFields(POSPostingProfile);
                TempPOSPostingProfile.Insert();
            until POSPostingProfile.Next() = 0;
    end;

    local procedure CopyReal()
    var
        POSPOSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if POSPOSPostingProfile.FindSet() then
            repeat
                TempExistingPOSPostingProfiles := POSPOSPostingProfile;
                TempExistingPOSPostingProfiles.Insert();
            until POSPOSPostingProfile.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInPOSPOSPostingProfile(var POSPOSPostingProfile: Record "NPR POS Posting Profile"; var WantedStartingNo: Code[20]) CalculatedNo: Code[20]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        POSPOSPostingProfile.SetRange(Code, CalculatedNo);

        if POSPOSPostingProfile.FindFirst() then begin
            WantedStartingNo := HelperFunctions.FormatCode20(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInPOSPOSPostingProfile(POSPOSPostingProfile, WantedStartingNo);
        end;
    end;
}