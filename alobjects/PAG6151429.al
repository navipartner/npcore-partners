page 6151429 "Magento Item Custom Opt. Value"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Item Custom Option Value';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = CardPart;
    SourceTable = "Magento Item Custom Opt. Value";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                }
                field("Custom Option No.";"Custom Option No.")
                {
                }
                field("Custom Option Value Line No.";"Custom Option Value Line No.")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field(Description;Description)
                {
                }
                field(Price;Price)
                {
                }
                field("Price Type";"Price Type")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnModifyRecord(): Boolean
    begin
        OnModifyTrigger();
    end;

    local procedure OnModifyTrigger()
    var
        ItemCustomOptValue: Record "Magento Item Custom Opt. Value";
    begin
        if not Enabled then begin
          if ItemCustomOptValue.Get("Item No.","Custom Option No.","Custom Option Value Line No.") then
            ItemCustomOptValue.Delete(true);
          exit;
        end;

        if ItemCustomOptValue.Get("Item No.","Custom Option No.","Custom Option Value Line No.") then begin
          ItemCustomOptValue.TransferFields(Rec);
          ItemCustomOptValue.Modify(true);
          exit;
        end;

        ItemCustomOptValue.Init;
        ItemCustomOptValue := Rec;
        ItemCustomOptValue.Insert(true);
    end;

    procedure SetSourceTable(ItemNo: Code[20];CustomOptionNo: Code[20])
    var
        CustomOption: Record "Magento Custom Option";
        CustomOptionValue: Record "Magento Custom Option Value";
        ItemCustomOptValue: Record "Magento Item Custom Opt. Value";
    begin
        DeleteAll;
        if (not CustomOption.Get(CustomOptionNo)) or
           not (CustomOption.Type in [CustomOption.Type::SelectDropDown,CustomOption.Type::SelectRadioButtons,
                                            CustomOption.Type::SelectCheckbox,CustomOption.Type::SelectMultiple]) then begin
          CurrPage.Update(false);
          exit;
        end;

        CustomOptionValue.SetRange("Custom Option No.",CustomOptionNo);
        if CustomOptionValue.FindSet then
          repeat
            Init;
            if ItemCustomOptValue.Get(ItemNo,CustomOptionValue."Custom Option No.",CustomOptionValue."Line No.") then
              Rec := ItemCustomOptValue
            else begin
              Init;
              "Item No." := ItemNo;
              "Custom Option No." := CustomOptionValue."Custom Option No.";
              "Custom Option Value Line No." := CustomOptionValue."Line No.";
              Enabled := false;
            end;
            Insert;
          until CustomOptionValue.Next = 0;

        CurrPage.Update(false);
    end;
}

