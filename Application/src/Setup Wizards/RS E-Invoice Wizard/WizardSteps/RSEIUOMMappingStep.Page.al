page 6184727 "NPR RS EI UOM Mapping Step"
{
    Caption = 'Unit Of Measure Mapping Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR RS EI UOM Mapping";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(UnitOfMeasures)
            {
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Unit of Measure field.';
                }
                field("RS EI UOM Code"; Rec."RS EI UOM Code")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the UOM Code field.';
                    trigger OnDrillDown()
                    var
                        RSAllowedUOM: Record "NPR RS EI Allowed UOM";
                        RSAllowedUOMList: Page "NPR RS EI Allowed UOM";
                    begin
                        Commit();
                        RSAllowedUOMList.LookupMode := true;
                        RSAllowedUOMList.SetTableView(RSAllowedUOM);
                        if not (RSAllowedUOMList.RunModal() = Action::LookupOK) then
                            exit;
                        RSAllowedUOMList.GetRecord(RSAllowedUOM);
                        Rec."RS EI UOM Code" := RSAllowedUOM.Code;
                        Rec."RS EI UOM Name" := RSAllowedUOM.Name;
                        Rec.Modify();
                    end;

                    trigger OnValidate()
                    var
                        RSAllowedUOM: Record "NPR RS EI Allowed UOM";
                    begin
                        RSAllowedUOM.Get(Rec."RS EI UOM Code");
                        Rec."RS EI UOM Name" := RSAllowedUOM.Name;
                        Rec.Modify();
                    end;
                }
                field("RS EI UOM Name"; Rec."RS EI UOM Name")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the UOM Name field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Init")
            {
                Caption = 'Init Units of Measure';
                ApplicationArea = NPRRSEInvoice;
                Image = Start;
                ToolTip = 'Initializes the E-Invoice Unit of Measure records with non-existing units of measure.';

                trigger OnAction()
                var
                    UnitOfMeasure: Record "Unit of Measure";
                    EIUOMMapping: Record "NPR RS EI UOM Mapping";
                begin
                    if UnitOfMeasure.IsEmpty() then
                        exit;

                    UnitOfMeasure.FindSet();
                    repeat
                        if not EIUOMMapping.Get(UnitOfMeasure.Code) then begin
                            EIUOMMapping.Init();
                            EIUOMMapping."Unit of Measure" := UnitOfMeasure.Code;
                            EIUOMMapping.Insert();
                        end;
                    until UnitOfMeasure.Next() = 0;
                end;
            }
        }
    }


    internal procedure CopyRealToTemp()
    begin
        if RSEIUOMMapping.IsEmpty() then
            exit;
        RSEIUOMMapping.FindSet();
        repeat
            Rec.TransferFields(RSEIUOMMapping);
            if not Rec.Insert() then
                Rec.Modify();
        until RSEIUOMMapping.Next() = 0;
    end;

    internal procedure RSEIUOMMappingDataToCreate(): Boolean
    begin
        exit(Rec.FindFirst());
    end;

    internal procedure CreateRSEIUOMMappingData()
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet();
        repeat
            RSEIUOMMapping.TransferFields(Rec);
            if not RSEIUOMMapping.Insert() then
                RSEIUOMMapping.Modify();
        until Rec.Next() = 0;
    end;

    var
        RSEIUOMMapping: Record "NPR RS EI UOM Mapping";
}