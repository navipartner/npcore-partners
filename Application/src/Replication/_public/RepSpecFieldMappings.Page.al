page 6014672 "NPR Rep. Spec. Field Mappings"
{
    Caption = 'Replication Special Field Mappings';
    ContextSensitiveHelpPage = 'retail/replication/howto/replicationhowto.html';
    Editable = true;
    Extensible = true;
    PageType = Worksheet;
    SourceTable = "NPR Rep. Special Field Mapping";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Service Code"; Rec."Service Code")
                {
                    ToolTip = 'Specifies the Replication Service Code';
                    ApplicationArea = NPRRetail;
                    Editable = Not FieldsNonEditable;
                }

                field("EndPoint ID"; Rec."EndPoint ID")
                {
                    ToolTip = 'Specifies the Replication EndPoint ID.';
                    ApplicationArea = NPRRetail;
                    Editable = Not FieldsNonEditable;
                }

                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the Table ID.';
                    ApplicationArea = NPRRetail;
                    Editable = Not FieldsNonEditable;
                }

                field("Field ID"; Rec."Field ID")
                {
                    ToolTip = 'Specifies the Field ID.';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        FieldLookUpPage: Page "NPR Field Lookup";
                        FieldRec: Record Field;
                    begin
                        FieldRec.SetRange(TableNo, Rec."Table ID");
                        FieldRec.SetRange(Enabled, true);
                        FieldRec.SetRange(Class, FieldRec.Class::Normal);
                        FieldLookUpPage.SetTableView(FieldRec);
                        FieldLookUpPage.LookupMode(true);
                        IF FieldLookUpPage.RunModal() = Action::LookupOK then begin
                            FieldLookUpPage.GetRecord(FieldRec);
                            Rec.Validate("Field ID", FieldRec."No.");
                        end;
                    end;
                }

                field("Field Name"; Rec."Field Name")
                {
                    ToolTip = 'Specifies the table Field name.';
                    ApplicationArea = NPRRetail;
                }

                field("API Field Name"; Rec."API Field Name")
                {
                    ToolTip = 'Specifies the API field name.';
                    ApplicationArea = NPRRetail;
                }

                field("With Validation"; Rec."With Validation")
                {
                    ToolTip = 'Specifies if the Validate trigger should be executed when a new value is assigned to the field.';
                    ApplicationArea = NPRRetail;
                }

                field("Skip"; Rec.Skip)
                {
                    ToolTip = 'Specifies if any changes of the field value should be skipped.';
                    ApplicationArea = NPRRetail;
                }

                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the priority of the special field mapping.';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }

    trigger OnNewRecord(BelowXRec: Boolean)
    begin
        Rec."Service Code" := RepEndpoint."Service Code";
        Rec."EndPoint ID" := RepEndpoint."EndPoint ID";
        Rec."Table ID" := RepEndpoint."Table ID";
    end;

    procedure SetFieldsNonEditable()
    begin
        FieldsNonEditable := true;
    end;

    procedure SetReplicationEndpoint(RepEndpointIn: Record "NPR Replication Endpoint")
    begin
        RepEndpoint := RepEndpointIn;
    end;

    var
        FieldsNonEditable: Boolean;
        RepEndpoint: Record "NPR Replication Endpoint";
}
