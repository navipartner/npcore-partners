page 6184571 "NPR RS EI UOM Mapping"
{
    Caption = 'RS E-Invoice Units of Measure Mapping';
    ApplicationArea = NPRRSEInvoice;
    UsageCategory = Administration;
    PageType = List;
    SourceTable = "NPR RS EI UOM Mapping";
    Extensible = false;
    AdditionalSearchTerms = 'Serbia E-Invoice Units Of Measure Mapping,RS E Invoice Units Of Measure Mapping';

    layout
    {
        area(Content)
        {
            repeater(UnitOfMeasures)
            {
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("RS EI UOM Code"; Rec."RS EI UOM Code")
                {
                    ToolTip = 'Specifies the value of the UOM Code field.';
                    ApplicationArea = NPRRSEInvoice;

                    trigger OnDrillDown()
                    var
                        RSAllowedUOM: Record "NPR RS EI Allowed UOM";
                        RSAllowedUOMList: Page "NPR RS EI Allowed UOM";
                    begin
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
                    ToolTip = 'Specifies the value of the UOM Name field.';
                    ApplicationArea = NPRRSEInvoice;
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
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initializes the E-Invoice Unit of Measure records with non-existing units of measure.';
                ApplicationArea = NPRRSEInvoice;

                trigger OnAction()
                var
                    UnitOfMeasure: Record "Unit of Measure";
                    RSEIUOMMapping: Record "NPR RS EI UOM Mapping";
                begin
                    if UnitOfMeasure.IsEmpty() then
                        exit;

                    UnitOfMeasure.FindSet();
                    repeat
                        if not RSEIUOMMapping.Get(UnitOfMeasure.Code) then begin
                            RSEIUOMMapping.Init();
                            RSEIUOMMapping."Unit of Measure" := UnitOfMeasure.Code;
                            RSEIUOMMapping.Insert();
                        end;
                    until UnitOfMeasure.Next() = 0;
                end;
            }
        }
    }
}