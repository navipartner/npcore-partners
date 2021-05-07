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
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInPOSAuditProfile(ExistingAuditProfiles, Rec.Code);
                    end;
                }
                field("Sale Fiscal No. Series"; Rec."Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Fiscal No. Series field';

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Sale Fiscal No. Series field';

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing Fiscal No. Series field';

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fill Sale Fiscal No. On field';
                }
                field("Sales Ticket No. Series"; Rec."Sales Ticket No. Series")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    ToolTip = 'Specifies the value of the Sales Ticket No. Series field';

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Log Enabled field';
                }
                field("Audit Handler"; Rec."Audit Handler")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Handler field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSAuditProfile: Record "NPR POS Audit Profile" temporary;
                        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    begin
                        POSAuditProfile.TransferFields(Rec);
                        POSAuditLogMgt.LookupAuditHandler(POSAuditProfile);
                        Rec.TransferFields(POSAuditProfile);
                    end;
                }
                field("Allow Zero Amount Sales"; Rec."Allow Zero Amount Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Zero Amount Sales field';
                }
                field("Print Receipt On Sale Cancel"; Rec."Print Receipt On Sale Cancel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Receipt On Sale Cancel field';
                }
                field("Do Not Print Receipt on Sale"; Rec."Do Not Print Receipt on Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Do Not Print Receipt on Sale field';
                }
                field("Allow Printing Receipt Copy"; Rec."Allow Printing Receipt Copy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Printing Receipt Copy field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        ExistingAuditProfiles: Record "NPR POS Audit Profile" temporary;

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
                ExistingAuditProfiles := POSAuditProfile;
                ExistingAuditProfiles.Insert();
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