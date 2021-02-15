xmlport 6151140 "NPR M2 List Budgets"
{
    Caption = 'List Budgets';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ListBudgets)
        {
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable()
                        begin
                            ResponseCode := 'OK';
                        end;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                        textattribute(responsemessageid)
                        {
                            Occurrence = Optional;
                            XmlName = 'Id';

                            trigger OnBeforePassVariable()
                            begin

                                ResponseMessageId := '10';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin

                            ResponseMessage := 'Success';
                        end;
                    }
                    textelement(ExecutionTime)
                    {
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable()
                        begin

                            ExecutionTime := '1 (ms)';
                        end;
                    }
                }
                textelement(Budgets)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    tableelement(itembudgetnameresponse; "Item Budget Name")
                    {
                        MinOccurs = Zero;
                        XmlName = 'Budget';
                        SourceTableView = WHERE(Blocked = CONST(false));
                        fieldelement(Name; ItemBudgetNameResponse.Name)
                        {
                        }
                        fieldelement(Description; ItemBudgetNameResponse.Description)
                        {
                        }
                        textelement(AnalysisArea)
                        {

                            trigger OnBeforePassVariable()
                            begin

                                case ItemBudgetNameResponse."Analysis Area" of
                                    0:
                                        AnalysisArea := 'sales';
                                    1:
                                        AnalysisArea := 'purchase';
                                    else
                                        AnalysisArea := '';
                                end;
                            end;
                        }
                    }
                }
            }
        }
    }
}