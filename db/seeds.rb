# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#May want to re-seed
u = User.create!(email: 'speterlin12@gmail.com',password: 'password', name: 'Sebastian Peterlin', language: 'Spanish', language_level: 3, title: "Co-founder of smartXchange, IMBA 2016 Candidate at IE Business School", image: File.open("app/assets/images/Sebastian Peterlin.jpg"), birthdate: "1988-11-17", nationality: "American");
u1 = User.create!(email: 'example1@gmail.com',password: 'password', name: 'Patsy Purdy', language: 'Spanish', language_level: 4, title: "English teacher, Masters in Communications graduate", image: File.open("app/assets/images/Patsy Purdy.jpg"), age: 26, nationality: "Algerian");
u2 = User.create!(email: 'example2@gmail.com',password: 'password', name: 'Abigale Jacobson', language: 'French', language_level: 5, title: "Dentistry student at Complutense University of Madrid", image: File.open("app/assets/images/Abigale Jacobson.jpg"), age: 24, nationality: "Danish");
u3 = User.create!(email: 'example3@gmail.com',password: 'password', name: 'Coty Smitham', language: 'Portuguese', language_level: 2, title: "PhD in Mathematical Science at Complutense University of Madrid", image: File.open("app/assets/images/Coty Smitham.jpg"), age: 28, nationality: "Canadian");
u4 = User.create!(email: 'example4@gmail.com',password: 'password', name: 'Janet Collier', language: 'French', language_level: 3, title: "Master in Psychology at Autonomous University of Madrid", image: File.open("app/assets/images/Janet Collier.jpg"), age: 29, nationality: "French");
u5 = User.create!(email: 'example5@gmail.com',password: 'password', name: 'Shanie Macejkovic', language: 'English', language_level: 2, title: "Business Development at Bla Bla Car Madrid", image: File.open("app/assets/images/Shanie Macejkovic.jpg"), age: 26, nationality: "Czech");
u6 = User.create!(email: 'example6@gmail.com',password: 'password', name: 'Silvino Ines', language: 'English', language_level: 3, title: "World Traveler, previously Software Engineer at Palantir", image: File.open("app/assets/images/Silvino Ines.jpg"), age: 29, nationality: "Venezuelan");
u7 = User.create!(email: 'example7@gmail.com',password: 'password', name: 'Rufina Soria', language: 'English', language_level: 4, title: "Marketing and Social Media Representative at Just-eat", image: File.open("app/assets/images/Rufina Soria.jpg"), age: 26, nationality: "Colombian");
u8 = User.create!(email: 'example8@gmail.com',password: 'password', name: 'Ruben Paulino', language: 'English', language_level: 2, title: "UX/UI Designer, looking for work", image: File.open("app/assets/images/Ruben Paulino.jpg"), age: 26, nationality: "Bolivian");
u9 = User.create!(email: 'example9@gmail.com',password: 'password', name: 'Orland Rozas', language: 'English', language_level: 1, title: "Photographer at Orland Photography, Inc.", image: File.open("app/assets/images/Orland Rozas.jpg"), age: 30, nationality: "Argentinian");
u10 = User.create!(email: 'example10@gmail.com',password: 'password', name: 'The Beks', language: 'Italian', language_level: 2, title: "Dancer at B, Inc.", birthdate: '2001-6-13', nationality: "Italian");
u11 = User.create!(email: 'example11@gmail.com',password: 'password', name: 'The MLXO', language: 'German', language_level: 3, title: "Model at C, Inc.", birthdate: '2004-6-13', nationality: "French"); # French-Italian
u12 = User.create!(email: 'example12@gmail.com',password: 'password', name: 'The SMRGS', language: 'Spanish', language_level: 4, title: "Model at DD, Inc.", birthdate: '1995-6-13', nationality: "Turkish");
u13 = User.create!(email: 'example13@gmail.com',password: 'password', name: 'The SLNAMRGS', language: 'Danish', language_level: 4, title: "Hot Stuff", birthdate: '1995-6-13', nationality: "Turkish");

b1 = Board.create!(title: 'Spanish', description: 'Un tablero para aquellos que buscan aprender y practicar español. Un tablero donde puedes postear sobre encuentros potenciales, ofertas de la tutoría, extremidades profesionales, tus proyectos (tales como nuevos proyectos), acoplamientos a tu trabajo (tal como arte, diseño, desarrollo), y el material educativo, interesante, o el otro. Puedes subir o bajar una publicación (hacer que alguien o tu propia publicación sea más popular), comentar una publicación y seguir una publicación para que recibas todas las notificaciones para esa publicación. Estás limitado a 5 puestos, 10 votos y 10 comentarios por período de 24 horas :).');
b2 = Board.create!(title: 'Smart Jobs', description: 'A board where you can post about jobs offered and jobs wanted. Jobs could be, for example, translation services or blogging entries. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b3 = Board.create!(title: 'English', description: 'A board for those looking to learn and practice English. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b4 = Board.create!(title: 'Italian', description: 'A board for those looking to learn and practice Italian. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b5 = Board.create!(title: 'German', description: 'A board for those looking to learn and practice German. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b6 = Board.create!(title: 'French', description: 'A board for those looking to learn and practice French. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b7 = Board.create!(title: 'Portuguese', description: 'A board for those looking to learn and practice Portuguese. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b8 = Board.create!(title: 'Danish', description: 'A board for those looking to learn and practice Danish. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b9 = Board.create!(title: 'Hashtag', description: 'See all posts with the given hashtag!');
b10 = Board.create!(title: 'Python', description: 'A board for those looking to learn and practice Python programming. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b11 = Board.create!(title: 'Ruby On Rails', description: 'A board for those looking to learn and practice Ruby On Rails programming. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
# b12 = Board.create!(title: 'Swift', description: 'A board for those looking to learn and practice Swift programming. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');
b13 = Board.create!(title: 'Javascript', description: 'A board for those looking to learn and practice Javascript programming. A board where you can post about potential meetups, tutoring offers, professional tips, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).');

p1 = Package.create!(classification: 'Standard', description: 'Access to the Platform', price: 0)
p2 = Package.create!(classification: 'Premium', description: 'Access to conversations with persons of interest (Professors, Managers, CEOs, artists, etc), language learning aids (chatbots, smartXchange verified tutors, tutor materials), language related jobs listed on our platform, and more!', price: 4.99)
# languages = ["Spanish","English","German","French"]
# language_levels = [1,2,3,4,5,6,7,8,9,10]
# ages = [23,25,27,29,31,33,35,37]
# titles = ["Monetizing intuitive partnerships", "Deploying vertical web services", "Generating frictionless technologies", "Innovating world class niches", "Syndicate b2c niches", "Harnessing front-end metrics", "Generating b2c bandwidth", "Optimizing holistic systems"]





# 5.times do |n|
#   name  = Faker::Name.name
#   email = "example#{n+6}@gmail.com"
#   password = "password"
#   age = ages[rand(ages.count)]
#   language = languages[rand(languages.count)]
#   language_level = language_levels[rand(language_levels.count)]
#   title = titles[rand(titles.count)]
#   User.create!(name:  name,
#                age: age,
#                title: title,
#                email: email,
#                password: password,
#                language: language,
#                language_level: language_level
#                )
# end

# image: File.open("chair_images/Gym-Ergonomic.jpg")
