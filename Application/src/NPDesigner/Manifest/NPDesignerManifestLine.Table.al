table 6151257 "NPR NPDesignerManifestLine"
{
    DataClassification = CustomerContent;
    Extensible = false;
    Access = Internal;
    Caption = 'NPDesigner Manifest Line';

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR NPDesignerManifest".EntryNo;
            Caption = 'Entry No.';
        }
        field(2; LineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }

        field(10; AssetTableNumber; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Asset Table Number';
        }
        field(11; AssetId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Asset Id';
        }
        field(12; AssetPublicId; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Asset Public Id';
        }
        field(13; RenderWithTemplateId; Text[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Render With Design Layout';
        }
        field(20; RenderGroupOrder; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Render Order';
            InitValue = 1;
        }
        field(21; RenderGroup; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Group';
            InitValue = 1;
        }
    }

    keys
    {
        key(Key1; EntryNo, LineNo)
        {
            Clustered = true;
        }
        key(Key2; AssetTableNumber, AssetId)
        {
            Clustered = false;
        }
        key(Key3; EntryNo, RenderGroup, RenderGroupOrder)
        {
            Clustered = false;
        }

    }

    trigger OnInsert()
    var
        ManifestLine: Record "NPR NPDesignerManifestLine";
    begin
        if (LineNo = 0) then begin
            LineNo := 1;
            ManifestLine.SetFilter(EntryNo, '=%1', EntryNo);
            if (ManifestLine.FindLast()) then
                LineNo := ManifestLine.LineNo + 1;
        end;
    end;

}