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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInPOSAuditProfile(ExistingAuditProfiles, Code);
                    end;
                }
                field("Sale Fiscal No. Series"; "Sale Fiscal No. Series")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NoSeries: Record "No. Series";
                        NoSeriesList: Page "No. Series List";
                    begin
                        NoSeriesList.LookupMode := true;

                        IF "Sale Fiscal No. Series" <> '' then
                            if NoSeries.Get("Sale Fiscal No. Series") then
                                NoSeriesList.SetRecord(NoSeries);

                        if NoSeriesList.RunModal() = Action::LookupOK then begin
                            NoSeriesList.GetRecord(NoSeries);
                            "Sale Fiscal No. Series" := NoSeries.Code;
                            NoSeries.TestField("Default Nos.", true);
                        end;
                    end;
                }
                field("Credit Sale Fiscal No. Series"; "Credit Sale Fiscal No. Series")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NoSeries: Record "No. Series";
                        NoSeriesList: Page "No. Series List";
                    begin
                        NoSeriesList.LookupMode := true;

                        if "Credit Sale Fiscal No. Series" <> '' then
                            if NoSeries.Get("Credit Sale Fiscal No. Series") then
                                NoSeriesList.SetRecord(NoSeries);

                        if NoSeriesList.RunModal() = Action::LookupOK then begin
                            NoSeriesList.GetRecord(NoSeries);
                            "Credit Sale Fiscal No. Series" := NoSeries.Code;
                            NoSeries.TestField("Default Nos.", true);
                        end;
                    end;
                }
                field("Balancing Fiscal No. Series"; "Balancing Fiscal No. Series")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NoSeries: Record "No. Series";
                        NoSeriesList: Page "No. Series List";
                    begin
                        NoSeriesList.LookupMode := true;

                        IF "Balancing Fiscal No. Series" <> '' then
                            if NoSeries.Get("Balancing Fiscal No. Series") then
                                NoSeriesList.SetRecord(NoSeries);

                        if NoSeriesList.RunModal() = Action::LookupOK then begin
                            NoSeriesList.GetRecord(NoSeries);
                            "Balancing Fiscal No. Series" := NoSeries.Code;
                            NoSeries.TestField("Default Nos.", true);
                        end;
                    end;
                }
                field("Fill Sale Fiscal No. On"; "Fill Sale Fiscal No. On")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No. Series"; "Sales Ticket No. Series")
                {
                    ApplicationArea = All;
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NoSeries: Record "No. Series";
                        NoSeriesList: Page "No. Series List";
                    begin
                        NoSeriesList.LookupMode := true;

                        IF "Sales Ticket No. Series" <> '' then
                            if NoSeries.Get("Sales Ticket No. Series") then
                                NoSeriesList.SetRecord(NoSeries);

                        if NoSeriesList.RunModal() = Action::LookupOK then begin
                            NoSeriesList.GetRecord(NoSeries);
                            "Sales Ticket No. Series" := NoSeries.Code;
                            NoSeries.TestField("Default Nos.", true);
                        end;
                    end;
                }
                field("Audit Log Enabled"; "Audit Log Enabled")
                {
                    ApplicationArea = All;
                }
                field("Audit Handler"; "Audit Handler")
                {
                    ApplicationArea = All;

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
                field("Allow Zero Amount Sales"; "Allow Zero Amount Sales")
                {
                    ApplicationArea = All;
                }
                field("Print Receipt On Sale Cancel"; "Print Receipt On Sale Cancel")
                {
                    ApplicationArea = All;
                }
                field("Do Not Print Receipt on Sale"; "Do Not Print Receipt on Sale")
                {
                    ApplicationArea = All;
                }
                field("Allow Printing Receipt Copy"; "Allow Printing Receipt Copy")
                {
                    ApplicationArea = All;
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

    local procedure CheckIfNoAvailableInPOSAuditProfile(var POSAuditProfile: Record "NPR POS Audit Profile"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        POSAuditProfile.SetRange(Code, CalculatedNo);

        if POSAuditProfile.FindFirst() then begin
            HelperFunctions.FormatCode(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInPOSAuditProfile(POSAuditProfile, WantedStartingNo);
        end;
    end;
}