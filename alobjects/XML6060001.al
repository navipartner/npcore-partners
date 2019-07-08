xmlport 6060001 "GIM - Mapping Templates"
{
    Caption = 'GIM - Mapping Templates';

    schema
    {
        textelement(gim_templates)
        {
            tableelement("GIM - Document Type";"GIM - Document Type")
            {
                RequestFilterFields = Code,"Sender ID";
                XmlName = 'document_type';
                SourceTableView = SORTING(Code,"Sender ID");
                fieldelement(doc_type_code;"GIM - Document Type".Code)
                {
                }
                fieldelement(doc_type_sender_id;"GIM - Document Type"."Sender ID")
                {
                }
                fieldelement(raw_data_reader;"GIM - Document Type"."Raw Data Reader")
                {
                }
                fieldelement(data_type_validator;"GIM - Document Type"."Data Type Validator")
                {
                }
                fieldelement(data_mapper;"GIM - Document Type"."Data Mapper")
                {
                }
                fieldelement(data_verification;"GIM - Document Type"."Data Verification")
                {
                }
                fieldelement(data_creation;"GIM - Document Type"."Data Creation")
                {
                }
                fieldelement(default_notification_method;"GIM - Document Type"."Default Notification Method")
                {
                }
                fieldelement(recipient_email;"GIM - Document Type"."Recipient E-mail")
                {
                }
                fieldelement(ftp_search_folder;"GIM - Document Type"."FTP Search Folder")
                {
                }
                fieldelement(ftp_file_action_after_read;"GIM - Document Type"."FTP File Action After Read")
                {
                }
                fieldelement(ftp_archive_folder;"GIM - Document Type"."FTP Archive Folder")
                {
                }
                fieldelement(ftp_local_folder;"GIM - Document Type"."FTP Local Folder")
                {
                }
                fieldelement(ftp_host_name;"GIM - Document Type"."FTP Host Name")
                {
                }
                fieldelement(ftp_port;"GIM - Document Type"."FTP Port")
                {
                }
                fieldelement(ftp_username;"GIM - Document Type"."FTP Username")
                {
                }
                fieldelement(ftp_password;"GIM - Document Type"."FTP Password")
                {
                }
                fieldelement(ftp_active;"GIM - Document Type"."FTP Active")
                {
                }
                fieldelement(lfu_folder_active;"GIM - Document Type"."LFU Folder Active")
                {
                }
                fieldelement(lfu_search_folder;"GIM - Document Type"."LFU Search Folder")
                {
                }
                fieldelement(lfu_file_action_after_read;"GIM - Document Type"."LFU File Action After Read")
                {
                }
                fieldelement(lfu_archive_folder;"GIM - Document Type"."LFU Archive Folder")
                {
                }
                fieldelement(lfu_preview_type;"GIM - Document Type"."Preview Type")
                {
                }
                fieldelement(lfu_preview_provided_data_only;"GIM - Document Type"."Preview Provided Data Only")
                {
                }
                fieldelement(ws_active;"GIM - Document Type"."WS Active")
                {
                }
                fieldelement(data_format_code;"GIM - Document Type"."Data Format Code")
                {
                }
            }
            tableelement("GIM - Document Type Version";"GIM - Document Type Version")
            {
                XmlName = 'document_type_version';
                SourceTableView = SORTING(Code,"Sender ID","Version No.");
                fieldelement(doc_type_version_code;"GIM - Document Type Version".Code)
                {
                }
                fieldelement(doc_type_version_sender_id;"GIM - Document Type Version"."Sender ID")
                {
                }
                fieldelement(doc_type_version_version_no;"GIM - Document Type Version"."Version No.")
                {
                }
                fieldelement(doc_type_version_base;"GIM - Document Type Version".Base)
                {
                }
                fieldelement(doc_type_version_description;"GIM - Document Type Version".Description)
                {
                }

                trigger OnPreXmlItem()
                begin
                    if DocTypeFilter <> '' then
                      "GIM - Document Type Version".SetFilter(Code,DocTypeFilter);
                    if SenderIDFilter <> '' then
                      "GIM - Document Type Version".SetFilter("Sender ID",SenderIDFilter);
                end;
            }
            tableelement("GIM - Mapping Table Line";"GIM - Mapping Table Line")
            {
                XmlName = 'mapping_table_line';
                SourceTableView = SORTING("Document No.","Doc. Type Code","Sender ID","Version No.","Line No.") WHERE("Document No."=CONST(''));
                fieldelement(mapping_table_line_doc_no;"GIM - Mapping Table Line"."Document No.")
                {
                }
                fieldelement(mapping_table_line_column;"GIM - Mapping Table Line"."Column No.")
                {
                }
                fieldelement(mapping_table_line_table_ID;"GIM - Mapping Table Line"."Table ID")
                {
                }
                fieldelement(mapping_table_line_priority;"GIM - Mapping Table Line".Priority)
                {
                }
                fieldelement(find_record;"GIM - Mapping Table Line"."Find Record")
                {
                }
                fieldelement(if_found;"GIM - Mapping Table Line"."If Found")
                {
                }
                fieldelement(if_not_found;"GIM - Mapping Table Line"."If Not Found")
                {
                }
                fieldelement(data_action;"GIM - Mapping Table Line"."Data Action")
                {
                }
                fieldelement(indentation_level;"GIM - Mapping Table Line"."Buffer Indentation Level")
                {
                }
                fieldelement(mapping_table_line_doc_type;"GIM - Mapping Table Line"."Doc. Type Code")
                {
                }
                fieldelement(mapping_table_line_sender_ID;"GIM - Mapping Table Line"."Sender ID")
                {
                }
                fieldelement(mapping_table_line_version_no;"GIM - Mapping Table Line"."Version No.")
                {
                }
                fieldelement(mapping_table_line_line_no;"GIM - Mapping Table Line"."Line No.")
                {
                }
                fieldelement(mapping_table_line_note;"GIM - Mapping Table Line".Note)
                {
                }

                trigger OnPreXmlItem()
                begin
                    if DocTypeFilter <> '' then
                      "GIM - Mapping Table Line".SetFilter("Doc. Type Code",DocTypeFilter);
                    if SenderIDFilter <> '' then
                      "GIM - Mapping Table Line".SetFilter("Sender ID",SenderIDFilter);
                end;
            }
            tableelement("GIM - Mapping Table Field";"GIM - Mapping Table Field")
            {
                AutoSave = false;
                XmlName = 'mapping_table_field';
                SourceTableView = SORTING("Document No.","Doc. Type Code","Sender ID","Version No.","Mapping Table Line No.","Field ID") WHERE("Document No."=CONST(''));
                fieldelement(mapping_table_field_doc_no;"GIM - Mapping Table Field"."Document No.")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_column_no;"GIM - Mapping Table Field"."Column No.")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_table_id;"GIM - Mapping Table Field"."Table ID")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_field_id;"GIM - Mapping Table Field"."Field ID")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_field_type;"GIM - Mapping Table Field"."Field Type")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_field_add_info;"GIM - Mapping Table Field"."Field Additional Info")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_field_options;"GIM - Mapping Table Field"."Field Options")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_part_of_primary_key;"GIM - Mapping Table Field"."Part of Primary Key")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_value_type;"GIM - Mapping Table Field"."Value Type")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_const_value;"GIM - Mapping Table Field"."Const Value")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_column_id;"GIM - Mapping Table Field"."Column ID")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_no_series_code;"GIM - Mapping Table Field"."No. Series Code")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_no_series_code_rule;"GIM - Mapping Table Field"."No. Series Code Rule")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_find_filter;"GIM - Mapping Table Field"."Find Filter")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_modify_value;"GIM - Mapping Table Field"."Modify Value")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_filter_value_type;"GIM - Mapping Table Field"."Filter Value Type")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_filter_value;"GIM - Mapping Table Field"."Filter Value")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_use_on_line_no;"GIM - Mapping Table Field"."Use on Mapping Table Line No.")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_use_on_table_id;"GIM - Mapping Table Field"."Use on Table ID")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_use_on_field_id;"GIM - Mapping Table Field"."Use on Field ID")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_propagate;"GIM - Mapping Table Field"."Propagate To All Rows")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_validate;"GIM - Mapping Table Field"."Validate Field")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_enrichment;"GIM - Mapping Table Field"."Apply Enrichment")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_formatted_value;"GIM - Mapping Table Field"."Formatted Value")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_auto_created;"GIM - Mapping Table Field"."Automatically Created")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_from_table_id;"GIM - Mapping Table Field"."From Table ID")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_from_field_id;"GIM - Mapping Table Field"."From Field ID")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_mapped;"GIM - Mapping Table Field".Mapped)
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_priority;"GIM - Mapping Table Field".Priority)
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_indentation_level;"GIM - Mapping Table Field"."Buffer Indentation Level")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_doc_type;"GIM - Mapping Table Field"."Doc. Type Code")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_sender_id;"GIM - Mapping Table Field"."Sender ID")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_version_no;"GIM - Mapping Table Field"."Version No.")
                {
                    FieldValidate = no;
                }
                fieldelement(mapping_table_field_table_line_no;"GIM - Mapping Table Field"."Mapping Table Line No.")
                {
                    FieldValidate = no;
                }

                trigger OnPreXmlItem()
                begin
                    if DocTypeFilter <> '' then
                      "GIM - Mapping Table Field".SetFilter("Doc. Type Code",DocTypeFilter);
                    if SenderIDFilter <> '' then
                      "GIM - Mapping Table Field".SetFilter("Sender ID",SenderIDFilter);
                end;

                trigger OnBeforeInsertRecord()
                begin
                    MappingTableField := "GIM - Mapping Table Field";
                    if MappingTableField.Insert then;
                end;
            }
            tableelement("GIM - Mapping Table Field Spec";"GIM - Mapping Table Field Spec")
            {
                XmlName = 'mapping_table_field_spec';
                SourceTableView = SORTING("Document No.","Doc. Type Code","Sender ID","Version No.","Mapping Table Line No.","Field ID","Entry No.") WHERE("Document No."=CONST(''));
                fieldelement(mapping_table_field_spec_doc_no;"GIM - Mapping Table Field Spec"."Document No.")
                {
                }
                fieldelement(mapping_table_field_spec_column_no;"GIM - Mapping Table Field Spec"."Column No.")
                {
                }
                fieldelement(mapping_table_field_spec_table_id;"GIM - Mapping Table Field Spec"."Table ID")
                {
                }
                fieldelement(mapping_table_field_spec_field_id;"GIM - Mapping Table Field Spec"."Field ID")
                {
                }
                fieldelement(mapping_table_field_spec_entry_no;"GIM - Mapping Table Field Spec"."Entry No.")
                {
                }
                fieldelement(mapping_table_field_spec_map_to;"GIM - Mapping Table Field Spec"."Map To")
                {
                }
                fieldelement(mapping_table_field_spec_file_value;"GIM - Mapping Table Field Spec"."File Value")
                {
                }
                fieldelement(mapping_table_field_spec_doc_type_code;"GIM - Mapping Table Field Spec"."Doc. Type Code")
                {
                }
                fieldelement(mapping_table_field_spec_sender_id;"GIM - Mapping Table Field Spec"."Sender ID")
                {
                }
                fieldelement(mapping_table_field_spec_version_no;"GIM - Mapping Table Field Spec"."Version No.")
                {
                }
                fieldelement(mapping_table_field_spec_table_line_no;"GIM - Mapping Table Field Spec"."Mapping Table Line No.")
                {
                }
                fieldelement(mapping_table_field_spec_used_for;"GIM - Mapping Table Field Spec"."Used For")
                {
                }

                trigger OnPreXmlItem()
                begin
                    if DocTypeFilter <> '' then
                      "GIM - Mapping Table Field Spec".SetFilter("Doc. Type Code",DocTypeFilter);
                    if SenderIDFilter <> '' then
                      "GIM - Mapping Table Field Spec".SetFilter("Sender ID",SenderIDFilter);
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort()
    begin
        DocTypeFilter := "GIM - Document Type".GetFilter(Code);
        SenderIDFilter := "GIM - Document Type".GetFilter("Sender ID");
    end;

    var
        DocTypeFilter: Text;
        SenderIDFilter: Text;
        MappingTableField: Record "GIM - Mapping Table Field";
}

