rails_schema_to_slick_schema
============================

Simple Script that loads a db/schema.rb file from rails and produces scala slick objects as the result. (WIP)

Intentions
===========

+ To be a synchronization script between a rails environment and a scala environment that would
run before deployment to create all Scala Table objects

+ Allow access to rails database models in scala without much effort

+ Support companies moving from Rails backed to Scala backend (cause who does not like speed)
