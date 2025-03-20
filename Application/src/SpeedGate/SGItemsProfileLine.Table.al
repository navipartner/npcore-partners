table 6151135 "NPR SG ItemsProfileLine"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            TableRelation = "NPR SG ItemsProfile";
        }
        field(2; LineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(10; ItemNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Description := '';
                Description2 := '';

                if (Item.Get(ItemNo)) then begin
                    Description := Item.Description;
                    Description2 := Item."Description 2";
                end;
            end;
        }
        field(20; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(21; Description2; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description 2';
        }
        field(30; PresentationOrder; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Presentation Order';
            InitValue = 0;
        }

    }

    keys
    {
        key(Key1; Code, LineNo)
        {
            Clustered = true;
        }
        key(Key2; Code, PresentationOrder)
        {
            Clustered = false;
        }
    }

    trigger OnInsert()
    var
        ItemsProfileLine: Record "NPR SG ItemsProfileLine";
    begin
        if (Rec.LineNo = 0) then begin
            ItemsProfileLine.SetCurrentKey(Code, LineNo);
            ItemsProfileLine.SetFilter(Code, '=%1', Rec.Code);

            Rec.LineNo := 10000;
            if (ItemsProfileLine.FindLast()) then
                Rec.LineNo := ItemsProfileLine.LineNo + 10000;
        end;
    end;

}