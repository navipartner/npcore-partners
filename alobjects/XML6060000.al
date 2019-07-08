xmlport 6060000 "GIM - General Setup"
{
    Caption = 'GIM - General Setup';

    schema
    {
        textelement(gim_general_setup)
        {
            tableelement("No. Series";"No. Series")
            {
                RequestFilterFields = Code;
                XmlName = 'no_series';
                SourceTableView = SORTING(Code);
                fieldelement(no_series_code;"No. Series".Code)
                {
                }
                fieldelement(no_series_desc;"No. Series".Description)
                {
                }
                fieldelement(default_nos;"No. Series"."Default Nos.")
                {
                }
                fieldelement(manual_nos;"No. Series"."Manual Nos.")
                {
                }
                fieldelement(date_order;"No. Series"."Date Order")
                {
                }
                tableelement("No. Series Line";"No. Series Line")
                {
                    LinkFields = "Series Code"=FIELD(Code);
                    LinkTable = "No. Series";
                    LinkTableForceInsert = true;
                    XmlName = 'no_series_line';
                    SourceTableView = SORTING("Series Code","Line No.");
                    fieldelement(series_code;"No. Series Line"."Series Code")
                    {
                    }
                    fieldelement(no_series_line_no;"No. Series Line"."Line No.")
                    {
                    }
                    fieldelement(no_series_line_starting_date;"No. Series Line"."Starting Date")
                    {
                    }
                    fieldelement(no_series_line_starting_no;"No. Series Line"."Starting No.")
                    {
                    }
                    fieldelement(no_series_line_ending_no;"No. Series Line"."Ending No.")
                    {
                    }
                    fieldelement(no_series_line_warning_no;"No. Series Line"."Warning No.")
                    {
                    }
                    fieldelement(increment_by_no;"No. Series Line"."Increment-by No.")
                    {
                    }
                    fieldelement(no_series_line_open;"No. Series Line".Open)
                    {
                    }
                }
            }
            tableelement("GIM - Setup";"GIM - Setup")
            {
                XmlName = 'gim_setup';
                SourceTableView = SORTING("Primary Key");
                fieldelement(gim_setup_pk;"GIM - Setup"."Primary Key")
                {
                }
                fieldelement(imp_doc_nos;"GIM - Setup"."Import Document Nos.")
                {
                }
                fieldelement(sender_email;"GIM - Setup"."Sender E-mail")
                {
                }
                fieldelement(mailing_template;"GIM - Setup"."Mailing Templates")
                {
                }
            }
            tableelement("GIM - Data Format";"GIM - Data Format")
            {
                XmlName = 'data_format';
                SourceTableView = SORTING(Code);
                fieldelement(data_format_code;"GIM - Data Format".Code)
                {
                }
                fieldelement(data_format_desc;"GIM - Data Format".Description)
                {
                }
                fieldelement(csv_field_delimiter;"GIM - Data Format"."CSV Field Delimiter")
                {
                }
                fieldelement(csv_field_separator;"GIM - Data Format"."CSV Field Separator")
                {
                }
                fieldelement(csv_first_data_row;"GIM - Data Format"."CSV First Data Row")
                {
                }
                fieldelement(xls_first_data_row;"GIM - Data Format"."Excel First Data Row")
                {
                }
            }
            tableelement("GIM - Process Flow";"GIM - Process Flow")
            {
                XmlName = 'process_flow';
                SourceTableView = SORTING(Code);
                fieldelement(process_flow_code;"GIM - Process Flow".Code)
                {
                }
                fieldelement(doc_type_field_id;"GIM - Process Flow"."Doc. Type Field ID")
                {
                }
                fieldelement(process_flow_desc;"GIM - Process Flow".Description)
                {
                }
                fieldelement(process_flow_stage;"GIM - Process Flow".Stage)
                {
                }
                fieldelement(process_flow_pause;"GIM - Process Flow".Pause)
                {
                }
                fieldelement(notify_when;"GIM - Process Flow"."Notify When")
                {
                }
            }
            tableelement("GIM - Supported Data Type";"GIM - Supported Data Type")
            {
                XmlName = 'supported_data_type';
                SourceTableView = SORTING(Code);
                fieldelement(supported_data_type_code;"GIM - Supported Data Type".Code)
                {
                }
                fieldelement(supported_data_type_desc;"GIM - Supported Data Type".Description)
                {
                }
            }
            tableelement("GIM - Data Type Property";"GIM - Data Type Property")
            {
                LinkTableForceInsert = true;
                XmlName = 'data_type_property';
                SourceTableView = SORTING("Data Type",Property);
                fieldelement(data_type;"GIM - Data Type Property"."Data Type")
                {
                }
                fieldelement(property;"GIM - Data Type Property".Property)
                {
                }
                fieldelement(data_type_desc;"GIM - Data Type Property".Description)
                {
                }
            }
            tableelement("GIM - Supported Data Format";"GIM - Supported Data Format")
            {
                XmlName = 'supported_data_format';
                SourceTableView = SORTING(Extension);
                fieldelement(supp_data_format_extension;"GIM - Supported Data Format".Extension)
                {
                }
                fieldelement(supp_data_format_desc;"GIM - Supported Data Format".Description)
                {
                }
                fieldelement(value_lookup;"GIM - Supported Data Format"."Value Lookup Editable")
                {
                }
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
}

