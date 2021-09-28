page 6014672 "NPR Rep. Spec. Field Mappings"
{

    Caption = 'Replication Special Field Mappings';
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
                    ToolTip = 'Specifies the Service Code';
                    ApplicationArea = NPRRetail;
                    Editable = Not FieldsNonEditable;
                }
                field("EndPoint ID"; Rec."EndPoint ID")
                {
                    ToolTip = 'Specifies the EndPoint ID.';
                    ApplicationArea = NPRRetail;
                    Editable = Not FieldsNonEditable;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies Table ID.';
                    ApplicationArea = NPRRetail;
                    Editable = Not FieldsNonEditable;
                }
                field("Field ID"; Rec."Field ID")
                {
                    ToolTip = 'Specifies Field ID.';
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
                    ToolTip = 'Specifies Field Name.';
                    ApplicationArea = NPRRetail;
                }

                field("API Field Name"; Rec."API Field Name")
                {
                    ToolTip = 'Specifies API Field Name.';
                    ApplicationArea = NPRRetail;
                }

                field("With Validation"; Rec."With Validation")
                {
                    ToolTip = 'Specifies With Validation.';
                    ApplicationArea = NPRRetail;
                }

                field("Skip"; Rec.Skip)
                {
                    ToolTip = 'Specifies Skip.';
                    ApplicationArea = NPRRetail;
                }

                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies Priority.';
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