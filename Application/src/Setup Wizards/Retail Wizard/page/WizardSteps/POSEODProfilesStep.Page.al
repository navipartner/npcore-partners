page 6014656 "NPR POS EOD Profiles Step"
{
    Extensible = False;
    Caption = 'POS EOD Profiles';
    PageType = ListPart;
    SourceTable = "NPR POS End of Day Profile";
    SourceTableTemporary = true;
    DelayedInsert = true;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInPOSEndOfDayProfile(TempExistingEndOfDayProfiles, Rec.Code);
                    end;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("End of Day Type"; Rec."End of Day Type")
                {

                    ToolTip = 'Specifies the value of the End of Day Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Master POS Unit No."; Rec."Master POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the Master POS Unit No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSUnitList: Page "NPR POS Units Select";
                    begin
                        POSUnitList.LookupMode := true;
                        POSUnitList.Editable := false;
                        POSUnitList.SetRec(TempAllPOSUnit);

                        if Rec."Master POS Unit No." <> '' then
                            if TempAllPOSUnit.Get(Rec."Master POS Unit No.") then
                                POSUnitList.SetRecord(TempAllPOSUnit);

                        if POSUnitList.RunModal() = Action::LookupOK then begin
                            POSUnitList.GetRecord(TempAllPOSUnit);
                            Rec."Master POS Unit No." := TempAllPOSUnit."No.";
                        end;
                    end;
                }
                field("Z-Report UI"; Rec."Z-Report UI")
                {

                    ToolTip = 'Specifies the value of the Z-Report UI field';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report UI"; Rec."X-Report UI")
                {

                    ToolTip = 'Specifies the value of the X-Report UI field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Workshift UI"; Rec."Close Workshift UI")
                {

                    ToolTip = 'Specifies the value of the Close Workshift UI field';
                    ApplicationArea = NPRRetail;
                }
                field("Force Blind Counting"; Rec."Force Blind Counting")
                {

                    ToolTip = 'Specifies the value of the Force Blind Counting field';
                    ApplicationArea = NPRRetail;
                }
                field("SMS Profile"; Rec."SMS Profile")
                {

                    ToolTip = 'Specifies the value of the SMS Profile field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SMSTemplateHeader: Record "NPR SMS Template Header";
                        SMSTemplateList: Page "NPR SMS Template List";
                    begin
                        SMSTemplateList.LookupMode := true;

                        if Rec."SMS Profile" <> '' then
                            if SMSTemplateHeader.Get(Rec."SMS Profile") then
                                SMSTemplateList.SetRecord(SMSTemplateHeader);

                        if SMSTemplateList.RunModal() = Action::LookupOK then begin
                            SMSTemplateList.GetRecord(SMSTemplateHeader);
                            Rec."SMS Profile" := SMSTemplateHeader.Code;
                        end;
                    end;
                }
                field("Z-Report Number Series"; Rec."Z-Report Number Series")
                {

                    ToolTip = 'Specifies the value of the Z-Report Number Series field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ZReportNoSerie: Record "No. Series";
                        ZReportNoSeries: Page "No. Series List";
                    begin
                        ZReportNoSeries.LookupMode := true;

                        IF Rec."Z-Report Number Series" <> '' then
                            if ZReportNoSerie.Get(Rec."Z-Report Number Series") then
                                ZReportNoSeries.SetRecord(ZReportNoSerie);

                        if ZReportNoSeries.RunModal() = Action::LookupOK then begin
                            ZReportNoSeries.GetRecord(ZReportNoSerie);
                            Rec."Z-Report Number Series" := ZReportNoSerie.Code;
                        end;
                    end;
                }
                field("X-Report Number Series"; Rec."X-Report Number Series")
                {

                    ToolTip = 'Specifies the value of the X-Report Number Series field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        XReportNoSerie: Record "No. Series";
                        XReportNoSeries: Page "No. Series List";
                    begin
                        XReportNoSeries.LookupMode := true;

                        IF Rec."X-Report Number Series" <> '' then
                            if XReportNoSerie.Get(Rec."X-Report Number Series") then
                                XReportNoSeries.SetRecord(XReportNoSerie);

                        if XReportNoSeries.RunModal() = Action::LookupOK then begin
                            XReportNoSeries.GetRecord(XReportNoSerie);
                            Rec."X-Report Number Series" := XReportNoSerie.Code;
                        end;
                    end;
                }
                field("Show Zero Amount Lines"; Rec."Show Zero Amount Lines")
                {

                    ToolTip = 'Specifies the value of the Show Zero Amount Lines field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        TempExistingEndOfDayProfiles: Record "NPR POS End of Day Profile" temporary;
        TempAllPOSUnit: Record "NPR POS Unit" temporary;

    procedure SetGlobals(var TempPOSUnit: Record "NPR POS Unit" temporary)
    begin
        TempAllPOSUnit.DeleteAll();

        if TempPOSUnit.FindSet() then
            repeat
                TempAllPOSUnit := TempPOSUnit;
                TempAllPOSUnit."POS Store Code" := '';
                TempAllPOSUnit.Insert(false);
                TempAllPOSUnit."POS Store Code" := TempPOSUnit."POS Store Code";
                TempAllPOSUnit.Modify(false);
            until TempPOSUnit.Next() = 0;

        if TempAllPOSUnit.FindSet() then;
    end;

    procedure GetRec(var TempPOSEndOfDayProfile: Record "NPR POS End of Day Profile")
    begin
        TempPOSEndOfDayProfile.Copy(Rec);
    end;

    procedure CreatePOSEndOfDayProfileData()
    var
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
    begin
        if Rec.FindSet() then
            repeat
                POSEndOfDayProfile := Rec;
                if not POSEndOfDayProfile.Insert() then
                    POSEndOfDayProfile.Modify();
            until Rec.Next() = 0;
    end;

    procedure POSEndOfDayProfileDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempPOSEndOfDayProfile: Record "NPR POS End of Day Profile")
    var
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
    begin
        TempPOSEndOfDayProfile.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSEndOfDayProfile := Rec;
                TempPOSEndOfDayProfile.Insert();
            until Rec.Next() = 0;

        TempPOSEndOfDayProfile.Init();
        if POSEndOfDayProfile.FindSet() then
            repeat
                TempPOSEndOfDayProfile.TransferFields(POSEndOfDayProfile);
                TempPOSEndOfDayProfile.Insert();
            until POSEndOfDayProfile.Next() = 0;
    end;

    local procedure CopyReal()
    var
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
    begin
        if POSEndOfDayProfile.FindSet() then
            repeat
                TempExistingEndOfDayProfiles := POSEndOfDayProfile;
                TempExistingEndOfDayProfiles.Insert();
            until POSEndOfDayProfile.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInPOSEndOfDayProfile(var POSEndOfDayProfile: Record "NPR POS End of Day Profile"; var WantedStartingNo: Code[20]) CalculatedNo: Code[20]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        POSEndOfDayProfile.SetRange(Code, CalculatedNo);

        if POSEndOfDayProfile.FindFirst() then begin
            WantedStartingNo := HelperFunctions.FormatCode20(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInPOSEndOfDayProfile(POSEndOfDayProfile, WantedStartingNo);
        end;
    end;
}
