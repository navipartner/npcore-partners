page 6151428 "Magento Item Custom Options"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Item Custom Options';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Magento Item Custom Option";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Item No.";"Item No.")
            {
                Caption = 'Item No.';
            }
            group("Custom Options")
            {
                Caption = 'Custom Options';
                repeater(Control6150615)
                {
                    ShowCaption = false;
                    field(Enabled;Enabled)
                    {
                    }
                    field("Custom Option No.";"Custom Option No.")
                    {
                    }
                    field(Description;Description)
                    {
                    }
                    field(Type;Type)
                    {
                    }
                    field(Required;Required)
                    {
                    }
                    field("Max Length";"Max Length")
                    {
                    }
                    field(Position;Position)
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
            part(OptionValues;"Magento Item Custom Opt. Value")
            {
                Caption = 'Values';
                SubPageLink = "Item No."=FIELD("Item No."),
                              "Custom Option No."=FIELD("Custom Option No.");
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.OptionValues.PAGE.SetSourceTable("Item No.","Custom Option No.");
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateForeColors();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        OnModifyTrigger();
    end;

    trigger OnOpenPage()
    begin
        SetSourceTable();
    end;

    var
        ItemNo: Code[20];
        EnabledForeColor: Integer;
        PriceForeColor: Integer;

    local procedure OnModifyTrigger()
    var
        ItemCustomOption: Record "Magento Item Custom Option";
    begin
        if not Enabled then begin
          if ItemCustomOption.Get("Item No.","Custom Option No.") then
            ItemCustomOption.Delete(true);
          exit;
        end;

        if ItemCustomOption.Get("Item No.","Custom Option No.") then begin
          ItemCustomOption.TransferFields(Rec);
          ItemCustomOption.Modify(true);
          exit;
        end;

        ItemCustomOption.Init;
        ItemCustomOption := Rec;
        ItemCustomOption.Insert(true);
    end;

    procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    procedure SetEnabledFilter()
    begin
        SetRange(Enabled,true);
    end;

    procedure SetSourceTable()
    var
        CustomOption: Record "Magento Custom Option";
        Item: Record Item;
        ItemCustomOption: Record "Magento Item Custom Option";
        RecRef: RecordRef;
    begin
        if ItemNo = '' then
          exit;

        RecRef.GetTable(Rec);
        if not RecRef.IsTemporary then
          exit;
        RecRef.Close;

        DeleteAll;

        if not Item.Get(ItemNo) then
          exit;

        if not CustomOption.FindSet then
          exit;


        repeat
          Init;
          if ItemCustomOption.Get(ItemNo,CustomOption."No.") then
            Rec := ItemCustomOption
          else begin
            "Item No." := ItemNo;
            "Custom Option No." := CustomOption."No.";
            Enabled := false;
          end;
          Insert;
        until CustomOption.Next = 0;

        FindFirst;

        CurrPage.Update(false);
    end;

    local procedure UpdateForeColors()
    begin
        EnabledForeColor := 0;
        PriceForeColor := 0;

        if not (Type in [Type::SelectDropDown,Type::SelectRadioButtons,Type::SelectCheckbox,Type::SelectMultiple]) then
          exit;

        CalcFields("Enabled Option Values");

        PriceForeColor := 10061943; //Light Slate Gray 119-136-153
        if Enabled and ("Enabled Option Values" <= 0) then
          EnabledForeColor := 17919;  //Orange Red 255-69-0
    end;
}

