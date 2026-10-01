table 6059919 "NPR API BI Allowed Table"
{
    Caption = 'BI API Allowed Table';
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;
    DataPerCompany = false;
    LookupPageId = "NPR API BI Allowed Tables";
    DrillDownPageId = "NPR API BI Allowed Tables";

    fields
    {
        field(1; "Principal Type"; Enum "NPR API BI Principal Type")
        {
            Caption = 'Principal Type';
            ToolTip = 'Specifies whether the table is allowed for a NaviPartner API Key or for a single Entra ID application.';

            trigger OnValidate()
            begin
                // The id means something different in each namespace, so keeping it across a type
                // change would leave a row pointing at nothing while still looking valid.
                if (Rec."Principal Type" <> xRec."Principal Type") then
                    Clear(Rec."Principal Id");
            end;
        }
        field(2; "Principal Id"; Guid)
        {
            Caption = 'Principal Id';
            NotBlank = true;
            ToolTip = 'Specifies the NaviPartner API Key Id, or the Client Id of the Entra ID application, that the table is allowed for.';
            TableRelation = if ("Principal Type" = const("NP API Key")) "NPR NaviPartner API Key".Id
            else
            if ("Principal Type" = const("Entra App")) "AAD Application"."Client Id";

            trigger OnLookup()
            begin
                LookupPrincipal();
            end;
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            ToolTip = 'Specifies the table that the principal is allowed to read through the BI API.';

            trigger OnValidate()
            var
                BIAccess: Codeunit "NPR API BI Access";
            begin
                BIAccess.TestTableSupported(Rec."Table No.");
            end;
        }
    }

    keys
    {
        key(PK; "Principal Type", "Principal Id", "Table No.")
        {
            Clustered = true;
        }
        // Every BI read is incremental and orders by this, so a table without the key cannot be read
        // through the endpoint at all. This one configures that endpoint, so it carries the key too.
        key(RowVersion; SystemRowVersion)
        {
        }
    }

    trigger OnInsert()
    begin
        ValidateRow();
    end;

    trigger OnModify()
    begin
        ValidateRow();
    end;

    trigger OnRename()
    begin
        ValidateRow();
    end;

    // Field validation does not run on direct assignment, so a config package or an upgrade codeunit
    // could otherwise store a row naming a table the endpoint refuses to serve.
    local procedure ValidateRow()
    var
        BIAccess: Codeunit "NPR API BI Access";
    begin
        Rec.TestField("Principal Id");
        Rec.TestField("Table No.");
        BIAccess.TestTableSupported(Rec."Table No.");
    end;

    internal procedure GetPrincipalDescription(): Text
    var
        AADApplication: Record "AAD Application";
        NPAPIKey: Record "NPR NaviPartner API Key";
    begin
        case Rec."Principal Type" of
            Rec."Principal Type"::"NP API Key":
                if NPAPIKey.Get(Rec."Principal Id") then
                    exit(NPAPIKey.Description);
            Rec."Principal Type"::"Entra App":
                if AADApplication.Get(Rec."Principal Id") then
                    exit(AADApplication.Description);
        end;
        exit('');
    end;

    internal procedure GetTableCaption(): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if Rec."Table No." = 0 then
            exit('');
        if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Rec."Table No.") then
            exit('');
        exit(AllObjWithCaption."Object Caption");
    end;

    local procedure LookupPrincipal()
    var
        AADApplication: Record "AAD Application";
        NPAPIKey: Record "NPR NaviPartner API Key";
    begin
        case Rec."Principal Type" of
            Rec."Principal Type"::"NP API Key":
                if (Page.RunModal(Page::"NPR NP API Key List", NPAPIKey) = Action::LookupOK) then
                    Rec.Validate("Principal Id", NPAPIKey.Id);
            Rec."Principal Type"::"Entra App":
                if (Page.RunModal(Page::"AAD Application List", AADApplication) = Action::LookupOK) then
                    Rec.Validate("Principal Id", AADApplication."Client Id");
        end;
    end;
}
