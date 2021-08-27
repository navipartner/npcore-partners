page 6014654 "NPR POS Audit Profiles Step"
{
    Caption = 'POS Audit Profiles';
    PageType = ListPart;
    SourceTable = "NPR POS Audit Profile";
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

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInPOSAuditProfile(TempExistingAuditProfiles, Rec.Code);
                    end;
                }
                field("Sale Fiscal No. Series"; Rec."Sale Fiscal No. Series")
                {

                    ToolTip = 'Specifies the value of the Sale Fiscal No. Series field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NoSeries: Record "No. Series";
                        NoSeriesList: Page "No. Series List";
                    begin
                        NoSeriesList.LookupMode := true;

                        IF Rec."Sale Fiscal No. Series" <> '' then
                            if NoSeries.Get(Rec."Sale Fiscal No. Series") then
                                NoSeriesList.SetRecord(NoSeries);

                        if NoSeriesList.RunModal() = Action::LookupOK then begin
                            NoSeriesList.GetRecord(NoSeries);
                            Rec."Sale Fiscal No. Series" := NoSeries.Code;
                            NoSeries.TestField("Default Nos.", true);
                        end;
                    end;
                }
                field("Credit Sale Fiscal No. Series"; Rec."Credit Sale Fiscal No. Series")
                {

                    ToolTip = 'Specifies the value of the Credit Sale Fiscal No. Series field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NoSeries: Record "No. Series";
                        NoSeriesList: Page "No. Series List";
                    begin
                        NoSeriesList.LookupMode := true;

                        if Rec."Credit Sale Fiscal No. Series" <> '' then
                            if NoSeries.Get(Rec."Credit Sale Fiscal No. Series") then
                                NoSeriesList.SetRecord(NoSeries);

                        if NoSeriesList.RunModal() = Action::LookupOK then begin
                            NoSeriesList.GetRecord(NoSeries);
                            Rec."Credit Sale Fiscal No. Series" := NoSeries.Code;
                            NoSeries.TestField("Default Nos.", true);
                        end;
                    end;
                }
                field("Balancing Fiscal No. Series"; Rec."Balancing Fiscal No. Series")
                {

                    ToolTip = 'Specifies the value of the Balancing Fiscal No. Series field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NoSeries: Record "No. Series";
                        NoSeriesList: Page "No. Series List";
                    begin
                        NoSeriesList.LookupMode := true;

                        IF Rec."Balancing Fiscal No. Series" <> '' then
                            if NoSeries.Get(Rec."Balancing Fiscal No. Series") then
                                NoSeriesList.SetRecord(NoSeries);

                        if NoSeriesList.RunModal() = Action::LookupOK then begin
                            NoSeriesList.GetRecord(NoSeries);
                            Rec."Balancing Fiscal No. Series" := NoSeries.Code;
                            NoSeries.TestField("Default Nos.", true);
                        end;
                    end;
                }
                field("Fill Sale Fiscal No. On"; Rec."Fill Sale Fiscal No. On")
                {

                    ToolTip = 'Specifies the value of the Fill Sale Fiscal No. On field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No. Series"; Rec."Sales Ticket No. Series")
                {

                    Lookup = true;
                    ToolTip = 'Specifies the value of the Sales Ticket No. Series field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NoSeries: Record "No. Series";
                        NoSeriesList: Page "No. Series List";
                    begin
                        NoSeriesList.LookupMode := true;

                        IF Rec."Sales Ticket No. Series" <> '' then
                            if NoSeries.Get(Rec."Sales Ticket No. Series") then
                                NoSeriesList.SetRecord(NoSeries);

                        if NoSeriesList.RunModal() = Action::LookupOK then begin
                            NoSeriesList.GetRecord(NoSeries);
                            Rec."Sales Ticket No. Series" := NoSeries.Code;
                            NoSeries.TestField("Default Nos.", true);
                        end;
                    end;
                }
                field("Audit Log Enabled"; Rec."Audit Log Enabled")
                {

                    ToolTip = 'Specifies the value of the Audit Log Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Audit Handler"; Rec."Audit Handler")
                {

                    ToolTip = 'Specifies the value of the Audit Handler field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempPOSAuditProfile: Record "NPR POS Audit Profile" temporary;
                        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    begin
                        TempPOSAuditProfile.TransferFields(Rec);
                        POSAuditLogMgt.LookupAuditHandler(TempPOSAuditProfile);
                        Rec.TransferFields(TempPOSAuditProfile);
                    end;
                }
                field("Allow Zero Amount Sales"; Rec."Allow Zero Amount Sales")
                {

                    ToolTip = 'Specifies the value of the Allow Zero Amount Sales field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Receipt On Sale Cancel"; Rec."Print Receipt On Sale Cancel")
                {

                    ToolTip = 'Specifies the value of the Print Receipt On Sale Cancel field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Printing Receipt Copy"; Rec."Allow Printing Receipt Copy")
                {

                    ToolTip = 'Specifies the value of the Allow Printing Receipt Copy field';
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
        TempExistingAuditProfiles: Record "NPR POS Audit Profile" temporary;

    procedure GetRec(var TempPOSAuditProfile: Record "NPR POS Audit Profile")
    begin
        TempPOSAuditProfile.Copy(Rec);
    end;

    procedure CreatePOSAuditProfileData()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if Rec.FindSet() then
            repeat
                POSAuditProfile := Rec;
                if not POSAuditProfile.Insert() then
                    POSAuditProfile.Modify();
            until Rec.Next() = 0;
    end;

    procedure POSAuditProfileDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempPOSAuditProfile: Record "NPR POS Audit Profile")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        TempPOSAuditProfile.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSAuditProfile := Rec;
                TempPOSAuditProfile.Insert();
            until Rec.Next() = 0;

        TempPOSAuditProfile.Init();
        if POSAuditProfile.FindSet() then
            repeat
                TempPOSAuditProfile.TransferFields(POSAuditProfile);
                TempPOSAuditProfile.Insert();
            until POSAuditProfile.Next() = 0;
    end;

    local procedure CopyReal()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if POSAuditProfile.FindSet() then
            repeat
                TempExistingAuditProfiles := POSAuditProfile;
                TempExistingAuditProfiles.Insert();
            until POSAuditProfile.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInPOSAuditProfile(var POSAuditProfile: Record "NPR POS Audit Profile"; var WantedStartingNo: Code[20]) CalculatedNo: Code[20]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        POSAuditProfile.SetRange(Code, CalculatedNo);

        if POSAuditProfile.FindFirst() then begin
            WantedStartingNo := HelperFunctions.FormatCode20(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInPOSAuditProfile(POSAuditProfile, WantedStartingNo);
        end;
    end;
}