xmlport 6150701 "NPR POS Menu Export/Import"
{
    Caption = 'POS Menu Export/Import';
    Encoding = UTF8;
    FormatEvaluate = Xml;

    schema
    {
        textelement(POSMenus)
        {
            tableelement("POS Menu"; "NPR POS Menu")
            {
                AutoReplace = true;
                XmlName = 'POSMenu';
                fieldelement(Code; "POS Menu".Code)
                {
                }
                fieldelement(Description; "POS Menu".Description)
                {
                }
                fieldelement(Caption; "POS Menu".Caption)
                {
                }
                fieldelement(Tooltip; "POS Menu".Tooltip)
                {
                }
                fieldelement(Blocked; "POS Menu".Blocked)
                {
                }
                fieldelement(CustomerClassAttribute; "POS Menu"."Custom Class Attribute")
                {
                }
                fieldelement(RegisterType; "POS Menu"."Register Type")
                {
                }
                fieldelement(RegisterNo; "POS Menu"."Register No.")
                {
                }
                fieldelement(SalespersonCode; "POS Menu"."Salesperson Code")
                {
                }
                tableelement("POS Menu Button"; "NPR POS Menu Button")
                {
                    AutoReplace = true;
                    LinkFields = "Menu Code" = FIELD(Code);
                    LinkTable = "POS Menu";
                    MinOccurs = Zero;
                    XmlName = 'POSMenuButton';
                    fieldelement(MenuCode; "POS Menu Button"."Menu Code")
                    {
                    }
                    fieldelement(ID; "POS Menu Button".ID)
                    {
                    }
                    fieldelement(ParantID; "POS Menu Button"."Parent ID")
                    {
                    }
                    fieldelement(Ordinal; "POS Menu Button".Ordinal)
                    {
                    }
                    fieldelement(Path; "POS Menu Button".Path)
                    {
                    }
                    fieldelement(Level; "POS Menu Button".Level)
                    {
                    }
                    fieldelement(ButtonCaption; "POS Menu Button".Caption)
                    {
                    }
                    fieldelement(ButtonTooltip; "POS Menu Button".Tooltip)
                    {
                    }
                    fieldelement(ActionType; "POS Menu Button"."Action Type")
                    {
                    }
                    fieldelement(ActionCode; "POS Menu Button"."Action Code")
                    {
                    }
                    fieldelement(ButtonBlocked; "POS Menu Button".Blocked)
                    {
                    }
                    fieldelement(BackgroundColor; "POS Menu Button"."Background Color")
                    {
                    }
                    fieldelement(ForegroundColor; "POS Menu Button"."Foreground Color")
                    {
                    }
                    fieldelement(IconClass; "POS Menu Button"."Icon Class")
                    {
                    }
                    fieldelement(ButtonCustomClassAttribute; "POS Menu Button"."Custom Class Attribute")
                    {
                    }
                    fieldelement(Bold; "POS Menu Button".Bold)
                    {
                    }
                    fieldelement(FontSize; "POS Menu Button"."Font Size")
                    {
                    }
                    fieldelement(PositionX; "POS Menu Button"."Position X")
                    {
                    }
                    fieldelement(PositionY; "POS Menu Button"."Position Y")
                    {
                    }
                    fieldelement(Enabled; "POS Menu Button".Enabled)
                    {
                    }
                    fieldelement(ButtonRegisterType; "POS Menu Button"."Register Type")
                    {
                    }
                    fieldelement(ButtonRegisterNo; "POS Menu Button"."Register No.")
                    {
                    }
                    fieldelement(ButtonSalespersonCode; "POS Menu Button"."Salesperson Code")
                    {
                    }
                    tableelement("POS Parameter Value"; "NPR POS Parameter Value")
                    {
                        LinkFields = Code = FIELD("Menu Code"), ID = FIELD(ID);
                        LinkTable = "POS Menu Button";
                        XmlName = 'Parameters';
                        SourceTableView = WHERE("Table No." = CONST(6150701));
                        fieldelement(RecordID; "POS Parameter Value"."Record ID")
                        {
                        }
                        fieldelement(Name; "POS Parameter Value".Name)
                        {
                        }
                        fieldelement(Action; "POS Parameter Value"."Action Code")
                        {
                        }
                        fieldelement(DataType; "POS Parameter Value"."Data Type")
                        {
                        }
                        fieldelement(Value; "POS Parameter Value".Value)
                        {
                        }
                    }
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

