xmlport 6014698 "NPR Mnm Export Nav Objects"
{
    Caption = 'Export Nav Objects';
    DefaultFieldsValidation = false;
    DefaultNamespace = 'urn:microsoft-dynamics-schemas/codeunit/mnm_services';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(objects)
        {
            MaxOccurs = Once;
            textattribute(version_list_filter)
            {
                Occurrence = Optional;

                trigger OnAfterAssignVariable()
                begin
                    VersionListFilter := version_list_filter;
                end;
            }
            tableelement(Object; Object)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                MinOccurs = Zero;
                XmlName = 'object';
                SourceTableView = SORTING(Type, "Company Name", ID) WHERE(Type = FILTER(<> TableData & <> System & <> FieldNumber), "Company Name" = FILTER(= ''));
                fieldattribute(type; Object.Type)
                {
                }
                fieldattribute(id; Object.ID)
                {
                }
                fieldelement(name; Object.Name)
                {
                }
                fieldelement(version_list; Object."Version List")
                {
                }
                fieldelement(date; Object.Date)
                {
                }
                fieldelement(time; Object.Time)
                {
                }
                textelement(last_modified_at)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(last_modified_by)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }

                trigger OnPreXmlItem()
                begin
                    Object.SetFilter("Version List", VersionListFilter);
                end;

                trigger OnAfterInitRecord()
                begin
                    currXMLport.BreakUnbound;
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SelectLatestVersion;
    end;

    var
        ObjectLogEntryFound: Boolean;
        VersionListFilter: Text;
}

