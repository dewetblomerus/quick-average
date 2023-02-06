# Configuration for Credo

%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: [
        {Credo.Check.Consistency.ExceptionNames, false},
        {Credo.Check.Readability.ModuleDoc, false}
      ]
    }
  ]
}
