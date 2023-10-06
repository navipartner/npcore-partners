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
                    TextType = BigText;
                }
                textelement(ItemMagentoShortDescription)
                {
                    TextType = BigText;
                }
                trigger OnBeforeInsertRecord()
                var
                    Item: Record Item;
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    OutStr: OutStream;
                    ModifyItem: Boolean;
                begin
                    if not Item.Get(ItemNo) then
                        exit;
                    ModifyItem := false;
                    if ItemMagentoDescription.Length > 0 then begin
                        TempBlob.CreateOutStream(OutStr);
                        ItemMagentoDescription.Write(OutStr);
                        TempBlob.CreateInStream(InStr);
                        Item."NPR Magento Desc.".ImportStream(InStr, Format(Item."No.") + '-' + Format(CreateGuid()));
                        ModifyItem := true;
                    end;
                    if ItemMagentoShortDescription.Length > 0 then begin
                        Clear(TempBlob);
                        TempBlob.CreateOutStream(OutStr);
                        ItemMagentoShortDescription.Write(OutStr);
                        TempBlob.CreateInStream(InStr);
                        Item."NPR Magento Short Desc.".ImportStream(InStr, Format(Item."No.") + '-' + Format(CreateGuid()));
                        ModifyItem := true;
                    end;
                    if ModifyItem then begin
                        Item.Modify();
                        ModifiedCount += 1;
                    end;
                end;
            }
        }
    }

    trigger OnPostXmlPort()
    var
        Msg: Label 'Description updated successfully. Number of modified items: %1';
    begin
        if ModifiedCount > 0 then
            Message(Msg, ModifiedCount);
    end;

    var
        ModifiedCount: Integer;
}