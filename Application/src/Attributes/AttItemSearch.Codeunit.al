codeunit 6014597 "NPR Att. Item Search"
{
    // NPR5.34/ANEN/20170608 CASE 279662 Support for text search in attributes for item


    trigger OnRun()
    begin
    end;

    procedure SearchTextAttribute(SearchString: Text; AttributeCode: Code[20]; var Items: Record Item) Found: Boolean
    var
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        NPRAttributeKey: Record "NPR Attribute Key";
        FilterString: Text;
        Counter: Integer;
    begin
        if SearchString = '' then exit(false);

        Items.MarkedOnly(true);
        if Items.FindFirst() then begin
            repeat
                Items.Mark(false);
            until (0 = Items.Next());
        end;
        Items.MarkedOnly(false);


        NPRAttributeValueSet.Reset();
        FilterString := '@*' + SearchString + '*';
        NPRAttributeValueSet.SetFilter("Text Value", FilterString);
        if (AttributeCode <> '') then NPRAttributeValueSet.SetFilter("Attribute Code", '=%1', AttributeCode);
        if NPRAttributeValueSet.FindSet() then begin
            repeat
                if NPRAttributeKey.Get(NPRAttributeValueSet."Attribute Set ID") then begin
                    Counter := Counter + 1;
                    if Items.Get(NPRAttributeKey."MDR Code PK") then Items.Mark(true);
                end;
            until ((0 = NPRAttributeValueSet.Next()) or (Counter = 100));
        end else begin
            exit(false);
        end;

        exit(true);
    end;

}

