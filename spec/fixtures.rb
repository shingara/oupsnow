Project.fixture {{
  :name => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
}}
