User.blueprint {
  login { /\w+/.gen }
  email { "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com"}
  password  { "tintinpouet"}
  password_confirmation { 'tintinpouet' }
  global_admin { false }
}

User.blueprint(:admin) do
  login { 'admin' }
  email { "#{/\w+/.gen}.#{/\w+/.gen}@gmail.com" }
  password { "tintinpouet" }
  password_confirmation { 'tintinpouet' }
  global_admin { true }
end

Function.blueprint(:admin) do
  name { /\w+/.gen }
  project_admin { false }
end

Function.blueprint do
  name { 'Admin' }
  project_admin { true }
end

Project.blueprint do
  name { /\w+/.gen }
  description { (0..3).of { /[:paragraph:]/.generate }.join("\n") }
end

