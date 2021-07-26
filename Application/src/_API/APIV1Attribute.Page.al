page 6014515 "NPR APIV1 Attribute"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'NPRAttribute';
    DelayedInsert = true;
    EntityName = 'nprAttribute';
    EntitySetName = 'nprAttributes';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Attribute";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(codeCaption; Rec."Code Caption")
                {
                    Caption = 'codeCaption', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'name', Locked = true;
                }
                field(valueDatatype; Rec."Value Datatype")
                {
                    Caption = 'valueDatatype', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(filterCaption; Rec."Filter Caption")
                {
                    Caption = 'filterCaption', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'blocked', Locked = true;
                }
                field(global; Rec.Global)
                {
                    Caption = 'global', Locked = true;
                }
                field(importFileColumnNo; Rec."Import File Column No.")
                {
                    Caption = 'importFileColumnNo', Locked = true;
                }
                field(lookUpDescriptionFieldId; Rec."LookUp Description Field Id")
                {
                    Caption = 'lookUpDescriptionFieldId', Locked = true;
                }
                field(lookUpDescriptionFieldName; Rec."LookUp Description Field Name")
                {
                    Caption = 'lookUpDescriptionFieldName', Locked = true;
                }
                field(lookUpTable; Rec."LookUp Table")
                {
                    Caption = 'lookUpTable', Locked = true;
                }
                field(lookUpTableId; Rec."LookUp Table Id")
                {
                    Caption = 'lookUpTableId', Locked = true;
                }
                field(lookUpTableName; Rec."LookUp Table Name")
                {
                    Caption = 'lookUpTableName', Locked = true;
                }
                field(lookUpValueFieldId; Rec."LookUp Value Field Id")
                {
                    Caption = 'lookUpValueFieldId', Locked = true;
                }
                field(lookUpValueFieldName; Rec."LookUp Value Field Name")
                {
                    Caption = 'lookUpValueFieldName', Locked = true;
                }
                field(onFormat; Rec."On Format")
                {
                    Caption = 'onFormat', Locked = true;
                }
                field(onValidate; Rec."On Validate")
                {
                    Caption = 'onValidate', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
