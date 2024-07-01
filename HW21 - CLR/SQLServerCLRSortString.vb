Public Class CLRFunctions    
    Public Shared Function SortString(ByVal Name As String) As String   
        Dim i As Integer 
        Dim returnValue As String 
        Dim stringArray() As String 
         
   ' split string into an array        
   stringArray = Split(Name, ",") 
    
   ' sort array values 
   Array.Sort(stringArray) 
    
   ' recreate string 
   returnValue = "" 
    
   For i = LBound(stringArray) To UBound(stringArray) 
       returnValue = returnValue & stringArray(i) & "," 
   Next i 

   Return returnValue 

    End Function   
End Class