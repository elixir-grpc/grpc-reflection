%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib", "test"],
        excluded: ["lib/proto", "test/support/*"]
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: true
    }
  ]
}
