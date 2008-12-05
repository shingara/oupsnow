Project.fixture {{
  :name => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
  :tickets => (0..10).of {Ticket.make}
}}

Ticket.fixture {{
  :title => /\w+/.gen,
  :description => (0..3).of { /[:paragraph:]/.generate }.join("\n"),
}}
