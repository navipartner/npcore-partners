codeunit 6060050 "NPR NpXml Value Item Worksh."
{
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        RecRef: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
        AttributeNo: Integer;
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrTextArray: array[99] of Text;
        Item: Record Item;
        GLSetup: Record "General Ledger Setup";
    begin
        if not NpXmlElement.Get(Rec."Xml Template Code", Rec."Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open(Rec."Table No.");
        RecRef.SetPosition(Rec."Record Position");
        if not RecRef.Find() then
            exit;


        if UpperCase(CopyStr(NpXmlElement."Element Name", 1, 9)) = 'ATTRIBUTE' then begin
            if Evaluate(AttributeNo, CopyStr(NpXmlElement."Element Name", 10, 2)) then begin
                case RecRef.Number of
                    DATABASE::Item:
                        begin
                            RecRef.SetTable(Item);
                            Clear(NPRAttrTextArray);
                            NPRAttrManagement.GetMasterDataAttributeValue(NPRAttrTextArray, RecRef.Number, Item."No.");
                            CustomValue := NPRAttrTextArray[AttributeNo];
                        end;
                end;
            end;
        end else begin
            case NpXmlElement."Element Name" of
                'SalesPriceCurrencyCode':
                    begin
                        GLSetup.Get();
                        CustomValue := GLSetup."LCY Code";
                    end;
                'PurchasePriceCurrencyCode':
                    begin
                        GLSetup.Get();
                        CustomValue := GLSetup."LCY Code";
                    end;
            end;
        end;


        RecRef.Close();

        Clear(RecRef);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify();
    end;

    var
        NpXmlElement: Record "NPR NpXml Element";

}

