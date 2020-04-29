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
                field(ExternalItemNo;ExternalItemNo)
                {
                    Caption = 'External Item No';
                }
                field(ExternalType;ExternalType)
                {
                    Caption = 'External Type';
                }
                field(VendorNo;VendorNo)
                {
                    Caption = 'Vendor No.';
                    TableRelation = Vendor."No.";
                }
                field(UnitOfMeasure;UnitOfMeasure)
                {
                    Caption = 'Unit Of Measure';
                    TableRelation = "Unit of Measure";
                }
                field(ItemNo;ItemNo)
                {
                    Caption = 'Item No.';
                    Editable = false;
                    TableRelation = Item."No.";
                }
                field(VariantCode;VariantCode)
                {
                    Caption = 'Variant Code';
                    Editable = false;
                }
                field(FoundItem;FoundItem)
                {
                    Caption = 'Found Item';
                    Editable = false;
                }
                field(SearchTime;Searchtime)
                {
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
        Searchtime := Round((Time - StartSearch)/1000,0.01);
    end;
}

