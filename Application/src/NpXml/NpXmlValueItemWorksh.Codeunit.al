codeunit 6060050 "NPR NpXml Value Item Worksh."
{
    // NPR5.22/BR/20160324      CASE 237658 Object Created
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento reference updated according to NC2.00

    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        RecRef: RecordRef;
        RecRef2: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
        AttributeNo: Integer;
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrTextArray: array[99] of Text;
        Item: Record Item;
        GLSetup: Record "General Ledger Setup";
    begin
        if not NpXmlElement.Get("Xml Template Code", "Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");
        if not RecRef.Find then
            exit;


        //CustomValue := GetVariantCode(RecRef,NpXmlElement."Field No.");
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
                        GLSetup.Get;
                        CustomValue := GLSetup."LCY Code";
                    end;
                'PurchasePriceCurrencyCode':
                    begin
                        GLSetup.Get;
                        CustomValue := GLSetup."LCY Code";
                    end;
                else begin
                        case NpXmlElement."Field No." of
                            Item.FieldNo("Unit Price"):
                                begin

                                end;


                        end;
                    end;
            end;
        end;


        RecRef.Close;

        Clear(RecRef);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    var
        Text000: Label 'Unsupported table: %1 %2 - codeunit 6059834 "NpXml Value External Item No." - NpXml Element: %3 %4';
        NpXmlElement: Record "NPR NpXml Element";

    local procedure GetVariantCode(RecRef: RecordRef; FieldNo: Integer) ItemVariantCode: Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        TMTicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        FieldRef: FieldRef;
    begin
        case RecRef.Number of
            DATABASE::Item:
                begin
                    RecRef.SetTable(Item);
                    exit(Item."No.");
                end;
            DATABASE::"Item Variant":
                begin
                    RecRef.SetTable(ItemVariant);
                    if ItemVariant.Code <> '' then
                        exit(ItemVariant."Item No." + '_' + ItemVariant.Code)
                    else
                        exit(ItemVariant."Item No.");
                end;
            DATABASE::"Sales Price":
                begin
                    RecRef.SetTable(SalesPrice);
                    if SalesPrice."Variant Code" <> '' then
                        exit(SalesPrice."Item No." + '_' + SalesPrice."Variant Code")
                    else
                        exit(SalesPrice."Item No.");
                end;
            DATABASE::"Sales Line Discount":
                begin
                    RecRef.SetTable(SalesLineDiscount);
                    SalesLineDiscount.SetRange(Type, SalesLineDiscount.Type::Item);
                    if SalesLineDiscount."Variant Code" <> '' then
                        exit(SalesLineDiscount.Code + '_' + SalesLineDiscount."Variant Code")
                    else
                        exit(SalesLineDiscount.Code);
                end;
            //-TMx.xx
            DATABASE::"NPR TM Ticket Admission BOM":
                begin
                    RecRef.SetTable(TMTicketAdmissionBOM);
                    SalesLineDiscount.SetRange(Type, SalesLineDiscount.Type::Item);
                    if TMTicketAdmissionBOM."Variant Code" <> '' then
                        exit(TMTicketAdmissionBOM."Item No." + '_' + TMTicketAdmissionBOM."Variant Code")
                    else
                        exit(TMTicketAdmissionBOM."Item No.");
                end;
        //+TMx.xx
        end;

        Error(Text000, RecRef.Number, RecRef.Caption, NpXmlElement."Xml Template Code", NpXmlElement."Element Name");
    end;
}

