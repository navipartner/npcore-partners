codeunit 6151452 "Magento NpXml Stock Status"
{
    // MAG1.16/TS/20150507  CASE 213379 Object created - Custom Values for NpXml
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.09/MHA /20180105  CASE 301053 Removed redundant CASE 'boolean' in SetRecRefCalcFieldFilter()

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NpXml Element";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get("Xml Template Code","Xml Element Line No.") then
          exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");
        if not RecRef.Find then
          exit;

        SetRecRefCalcFieldFilter(NpXmlElement,RecRef,RecRef2);
        CustomValue := Format(GetStockStatus(RecRef2),0,9);
        RecRef.Close;
        RecRef2.Close;

        Clear(RecRef);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    local procedure GetStockStatus(RecRef: RecordRef): Code[20]
    var
        Stock: Decimal;
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemVariant: Record "Item Variant";
    begin
        if GetStockQty(RecRef) > 0 then
          exit('1');

        exit('0');
    end;

    local procedure GetStockQty(var RecRef: RecordRef): Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        XMLMappingFilter: Record "NpXml Filter";
        Stock: Decimal;
        ItemNo: Code[20];
        VariantCode: Code[10];
        PosUnder: Integer;
    begin
        Stock := 0;
        case RecRef.Number of
          DATABASE::Item :
            begin
              RecRef.SetTable(Item);
              Item.CalcFields(Inventory,"Qty. on Sales Order");
              Stock := Item.Inventory - Item."Qty. on Sales Order";
              exit(Stock);
            end;
          DATABASE::"Item Variant" :
            begin
              RecRef.SetTable(ItemVariant);
              if not Item.Get(ItemVariant."Item No.") then
                exit(0);
              Item.SetRange("Variant Filter",ItemVariant.Code);
              Item.CalcFields(Inventory,"Qty. on Sales Order");
              Stock := Item.Inventory - Item."Qty. on Sales Order";
              exit(Stock);
            end;
        end;
        exit(0);
    end;

    local procedure SetRecRefCalcFieldFilter(NpXmlElement: Record "NpXml Element";RecRef: RecordRef;var RecRef2: RecordRef)
    var
        NpXmlFilter: Record "NpXml Filter";
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
    begin
        Clear(RecRef2);
        RecRef2.Open(RecRef.Number);
        RecRef2 := RecRef.Duplicate;

        NpXmlFilter.SetRange("Xml Template Code",NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.",NpXmlElement."Line No.");
        if NpXmlFilter.FindSet then
          repeat
            FieldRef2 := RecRef2.Field(NpXmlFilter."Field No.");
            case NpXmlFilter."Filter Type" of
              NpXmlFilter."Filter Type"::Constant :
                begin
                  if NpXmlFilter."Filter Value" <> '' then begin
                    case LowerCase(Format(FieldRef2.Type)) of
                      'boolean': FieldRef2.SetFilter('=%1',LowerCase(NpXmlFilter."Filter Value") in ['1','yes','ja','true']);
                      //-MAG2.09 [301053]
                      //'integer','option','boolean' :
                      'integer','option':
                      //+MAG2.09 [301053]
                        begin
                          if Evaluate(BufferDecimal,NpXmlFilter."Filter Value") then
                            FieldRef2.SetFilter('=%1',BufferDecimal);
                        end;
                      'decimal':
                        begin
                          if Evaluate(BufferInteger,NpXmlFilter."Filter Value") then
                            FieldRef2.SetFilter('=%1',BufferInteger);
                        end;
                      else
                        FieldRef2.SetFilter('=%1',NpXmlFilter."Filter Value");
                    end;
                  end;
                end;
              NpXmlFilter."Filter Type"::Filter :
                begin
                  FieldRef2.SetFilter(NpXmlFilter."Filter Value");
                end;
            end;
          until NpXmlFilter.Next = 0;

        case NpXmlElement."Iteration Type" of
          NpXmlElement."Iteration Type"::First :
            begin
              if RecRef2.FindFirst then
                RecRef2.SetRecFilter;
            end;
          NpXmlElement."Iteration Type"::Last :
            begin
              if RecRef2.FindLast then
                RecRef2.SetRecFilter;
            end;
        end;
    end;
}

