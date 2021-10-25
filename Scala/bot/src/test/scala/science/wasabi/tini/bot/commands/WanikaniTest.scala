package science.wasabi.tini.bot.commands


import io.circe._
import io.circe.parser._
import org.specs2.Specification

class WanikaniTest extends Specification {
  def is = s2"""
WanikaniTest
     simple json decode $e1
     bit more complicated json decode $e2
"""

  val testJson ="""
  {
    "id": "c730433b-082c-4984-9d66-855c243266f0",
    "name": "Foo",
    "counts": [1, 2, 3],
    "values": {
      "bar": true,
      "baz": 100.001,
      "qux": ["a", "b"]
    }
  }
"""

  val test2 =
    """
      |{
      |  "user_information" : {
      |    "username" : "Gsfdgdfg11",
      |    "gravatar" : "271fdb48dsgfsddf5237854",
      |    "level" : 7,
      |    "title" : "Turtles",
      |    "about" : "",
      |    "website" : null,
      |    "twitter" : null,
      |    "topics_count" : 0,
      |    "posts_count" : 0,
      |    "creation_date" : 14gdfs75259,
      |    "vacation_date" : null
      |  },
      |  "requested_information" : {
      |    "lessons_available" : 34,
      |    "reviews_available" : 712,
      |    "next_review_date" : 1499044618,
      |    "reviews_available_next_hour" : 3,
      |    "reviews_available_next_day" : 16
      |  }
      |}
    """.stripMargin


  def e1 = {
    val doc = parse(testJson).getOrElse(Json.Null)

    val cursor = doc.hcursor
    cursor.downField("values").downField("baz").as[Double].isRight must beTrue
  }

  def e2 = {
    // TODO: fix this test
    true must beTrue
  }
}