xmlport 6014404 "NPR ImportMagentoDescription"
{
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    TableSeparator = '<NewLine>';
    Caption = 'ImportItemDescription';
    FieldSeparator = '|';
    FieldDelimiter = '"';

    schema
    {
        textelement(root)
        {
            tableelement(Item; Item)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                textelement(ItemNo)
                {
                }
                textelement(ItemMagentoDescription)
                {
                }
                textelement(ItemMagentoShortDescription)
                {
                }
                trigger OnBeforeInsertRecord()
                var
                    Item: Record Item;
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    OutStr: OutStream;
                    ModifyItem: Boolean;
                    Msg: Label 'Description updated successfully';
                begin
                    if not Item.Get(ItemNo) then
                        exit;
                    ModifyItem := false;
                    if StrLen(ItemMagentoDescription) > 0 then begin
                        TempBlob.CreateOutStream(OutStr);
                        OutStr.WriteText(ItemMagentoDescription);
                        TempBlob.CreateInStream(InStr);
                        Item."NPR Magento Desc.".ImportStream(InStr, Format(Item."No.") + '-' + Format(CreateGuid()));
                        ModifyItem := true;
                    end;
                    if StrLen(ItemMagentoShortDescription) > 0 then begin
                        Clear(TempBlob);
                        TempBlob.CreateOutStream(OutStr);
                        OutStr.WriteText(ItemMagentoShortDescription);
                        TempBlob.CreateInStream(InStr);
                        Item."NPR Magento Short Desc.".ImportStream(InStr, Format(Item."No.") + '-' + Format(CreateGuid()));
                        ModifyItem := true;
                    end;
                    if ModifyItem then begin
                        Item.Modify();
                        Message(Msg);
                    end;
                end;
            }
        }
    }
}