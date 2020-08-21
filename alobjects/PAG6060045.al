page 6060045 "Item Search Page"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Item Search Page';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ExternalItemNo; ExternalItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'External Item No';
                }
                field(ExternalType; ExternalType)
                {
                    ApplicationArea = All;
                    Caption = 'External Type';
                }
                field(VendorNo; VendorNo)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No.';
                    TableRelation = Vendor."No.";
                }
                field(UnitOfMeasure; UnitOfMeasure)
                {
                    ApplicationArea = All;
                    Caption = 'Unit Of Measure';
                    TableRelation = "Unit of Measure";
                }
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    Editable = false;
                    TableRelation = Item."No.";
                }
                field(VariantCode; VariantCode)
                {
                    ApplicationArea = All;
                    Caption = 'Variant Code';
                    Editable = false;
                }
                field(FoundItem; FoundItem)
                {
                    ApplicationArea = All;
                    Caption = 'Found Item';
                    Editable = false;
                }
                field(SearchTime; Searchtime)
                {
                    ApplicationArea = All;
                    Caption = 'Search time (seconds)';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Search)
            {
                Caption = 'Search';
                Image = "Action";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    FindItem
                end;
            }
        }
    }

    var
        ItemNumberManagement: Codeunit "Item Number Management";
        ExternalItemNo: Text[50];
        ExternalType: Option All,VendorItemNo,Barcode,CrossReference,AlternativeNo;
        UnitOfMeasure: Code[10];
        VendorNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[1];
        FoundItem: Boolean;
        Searchtime: Decimal;

    local procedure FindItem()
    var
        StartSearch: Time;
    begin
        StartSearch := Time;
        FoundItem := ItemNumberManagement.FindItemInfo(ExternalItemNo,
                               ExternalType,
                               false,
                               UnitOfMeasure,
                               VendorNo,
                               ItemNo,
                               VariantCode);
        if not FoundItem then begin
            ItemNo := '';
            VariantCode := '';
        end;
        Searchtime := Round((Time - StartSearch) / 1000, 0.01);
    end;
}

