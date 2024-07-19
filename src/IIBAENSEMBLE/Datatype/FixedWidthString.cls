Class IIBAENSEMBLE.Datatype.FixedWidthString [ ClassType = datatype, ClientDataType = VARCHAR, OdbcType = VARCHAR, SqlCategory = STRING ]
{

/// MAXLEN determines the width of the field
Parameter MAXLEN = 250;

/// JUSTIFIED determines whether the value in the field is justified to the left or right.  The default is "L" for left.
Parameter JUSTIFIED As STRING = "L";

/// FILLER determines the value that is used to make up the full width of the field.  The default is space.
Parameter FILLER As STRING = " ";

}
