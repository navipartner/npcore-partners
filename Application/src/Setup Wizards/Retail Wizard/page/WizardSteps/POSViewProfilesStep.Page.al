page 6014655 "NPR POS View Profiles Step"
{
    Caption = 'POS View Profiles';
    PageType = ListPart;
    SourceTable = "NPR POS View Profile";
    SourceTableTemporary = true;

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
                        CheckIfNoAvailableInPOSViewProfile(ExistingViewProfiles, Rec.Code);
                    end;
                }
                field("Client Formatting Culture ID"; Rec."Client Formatting Culture ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Formatting Culture ID field';
                }
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Decimal Separator field';
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Thousands Separator field';
                }
                field("Client Date Separator"; Rec."Client Date Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Date Separator field';
                }
                field("POS Theme Code"; Rec."POS Theme Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Theme Code field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSTheme: Record "NPR POS Theme";
                        POSThemes: Page "NPR POS Themes";
                    begin
                        POSThemes.LookupMode := true;

                        IF Rec."POS Theme Code" <> '' then
                            if POSTheme.Get(Rec."POS Theme Code") then
                                POSThemes.SetRecord(POSTheme);

                        if POSThemes.RunModal() = Action::LookupOK then begin
                            POSThemes.GetRecord(POSTheme);
                            Rec."POS Theme Code" := POSTheme.Code;
                        end;
                    end;
                }
                field("Line Order on Screen"; Rec."Line Order on Screen")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        ExistingViewProfiles: Record "NPR POS View Profile" temporary;

    procedure GetRec(var TempPOSViewProfile: Record "NPR POS View Profile")
    begin
        TempPOSViewProfile.Copy(Rec);
    end;

    procedure CreatePOSViewProfileData()
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        if Rec.FindSet() then
            repeat
                POSViewProfile := Rec;
                if not POSViewProfile.Insert() then
                    POSViewProfile.Modify();
            until Rec.Next() = 0;
    end;

    procedure POSViewProfileDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempPOSViewProfile: Record "NPR POS View Profile")
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        TempPOSViewProfile.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSViewProfile := Rec;
                TempPOSViewProfile.Insert();
            until Rec.Next() = 0;

        TempPOSViewProfile.Init();
        if POSViewProfile.FindSet() then
            repeat
                TempPOSViewProfile.TransferFields(POSViewProfile);
                TempPOSViewProfile.Insert();
            until POSViewProfile.Next() = 0;
    end;

    local procedure CopyReal()
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        if POSViewProfile.FindSet() then
            repeat
                ExistingViewProfiles := POSViewProfile;
                ExistingViewProfiles.Insert();
            until POSViewProfile.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInPOSViewProfile(var POSViewProfile: Record "NPR POS View Profile"; var WantedStartingNo: Code[20]) CalculatedNo: Code[20]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        POSViewProfile.SetRange(Code, CalculatedNo);

        if POSViewProfile.FindFirst() then begin
            WantedStartingNo := HelperFunctions.FormatCode20(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInPOSViewProfile(POSViewProfile, WantedStartingNo);
        end;
    end;
}