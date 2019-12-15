xmlport 6014698 "Mnm Export Nav Objects"
{
    // NPR5.35/MHA /20170828  CASE 287440 Managed Nav Modules: Object created
    // NPR5.37/MHA /20171027  CASE 294593 Added version_list_filter
    // NPR5.38/MHA /20170104  CASE 282708 TNO module deprecated
    // NPR5.40/MHA /20180319  CASE 308406 Specific value removed from XmlVersionNo in order to be V2 extension compliant
    // NPR5.47/MHA /20181026  CASE 334073 Cleared LinksFields Property on <Object>(Object)

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
                    //-NPR5.37 [294593]
                    VersionListFilter := version_list_filter;
                    //+NPR5.37 [294593]
                end;
            }
            tableelement(Object;Object)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                MinOccurs = Zero;
                XmlName = 'object';
                SourceTableView = SORTING(Type,"Company Name",ID) WHERE(Type=FILTER(<>TableData&<>System&<>FieldNumber),"Company Name"=FILTER(=''));
                fieldattribute(type;Object.Type)
                {
                }
                fieldattribute(id;Object.ID)
                {
                }
                fieldelement(name;Object.Name)
                {
                }
                fieldelement(version_list;Object."Version List")
                {
                }
                fieldelement(date;Object.Date)
                {
                }
                fieldelement(time;Object.Time)
                {
                }
                textelement(last_modified_at)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;

                    trigger OnBeforePassVariable()
                    begin
                        //-NPR5.38 [282708]
                        // //-NPR5.37 [294593]
                        // IF NOT ObjectLogEntryFound THEN
                        //  EXIT;
                        //
                        // last_modified_at := FORMAT(TNOObjectLogEntry."Entry Time",0,9);
                        // //+NPR5.37 [294593]
                        //+NPR5.38 [282708]
                    end;
                }
                textelement(last_modified_by)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;

                    trigger OnBeforePassVariable()
                    begin
                        //-NPR5.38 [282708]
                        // //-NPR5.37 [294593]
                        // IF NOT ObjectLogEntryFound THEN
                        //  EXIT;
                        //
                        // last_modified_by := TNOObjectLogEntry."User ID";
                        // //+NPR5.37 [294593]
                        //+NPR5.38 [282708]
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    //-NPR5.38 [282708]
                    // //-NPR5.37 [294593]
                    // FindObjectLogEntry();
                    // //+NPR5.37 [294593]
                    //+NPR5.38 [282708]
                end;

                trigger OnPreXmlItem()
                begin
                    //-NPR5.37 [294593]
                    Object.SetFilter("Version List",VersionListFilter);
                    //+NPR5.37 [294593]
                end;

                trigger OnAfterInitRecord()
                begin
                    //-NPR5.37 [294593]
                    currXMLport.BreakUnbound;
                    //+NPR5.37 [294593]
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
        //-NPR5.37 [294593]
        SelectLatestVersion;
        //+NPR5.37 [294593]
    end;

    var
        ObjectLogEntryFound: Boolean;
        VersionListFilter: Text;
}

