#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6151113 "NPR SendGridDynamicTemplate"
{
    Access = Internal;
    Caption = 'Dynamic Templates';
    TableType = Temporary;
    LookupPageId = "NPR SendGridDynamicTemplates";
    DrillDownPageId = "NPR SendGridDynamicTemplates";

    fields
    {
        field(1; Id; Text[50])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; NPEmailAccountId; Integer)
        {
            Caption = 'NP Email Account Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR NP Email Account".AccountId;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    internal procedure AddFromJson(Json: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        Rec.Init();
#pragma warning disable AA0139
        Rec.Id := JsonHelper.GetJText(Json, 'id', true);
#pragma warning restore AA0139
        Rec.Name := CopyStr(JsonHelper.GetJText(Json, 'name', true), 1, MaxStrLen(Rec.Name));
        Rec.Insert();
    end;

    internal procedure UpdateFromDynamicTemplates(var TempDynamicTemplates: Record "NPR SendGridDynamicTemplate" temporary)
    var
        AlreadyExists: Boolean;
    begin
        if (TempDynamicTemplates.FindSet()) then
            repeat
                AlreadyExists := Rec.Get(TempDynamicTemplates.Id);
                Rec := TempDynamicTemplates;

                if (AlreadyExists) then
                    Rec.Modify()
                else
                    Rec.Insert();
            until TempDynamicTemplates.Next() = 0;

        Rec.Reset();
        if (Rec.FindSet(true)) then
            repeat
                if (not TempDynamicTemplates.Get(Rec.Id)) then
                    Rec.Delete();
            until Rec.Next() = 0;
    end;
}
#endif