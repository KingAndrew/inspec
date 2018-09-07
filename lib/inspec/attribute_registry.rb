require 'forwardable'
require 'singleton'
require 'inspec/objects/attribute'

module Inspec
  class AttributeRegistry
    include Singleton
    extend Forwardable

    attr_reader :list
    def_delegator :list, :each
    def_delegator :list, :[]
    def_delegator :list, :key?, :profile_exist?
    def_delegator :list, :select

    def self.find_attribute(name, profile)
      instance.find_attribute(name, profile)
    end

    def self.register_attribute(name, profile, options = {})
      instance.register_attribute(name, profile, options)
    end

    def self.register_profile_alias(name, alias_name)
      instance.register_profile_alias(name, alias_name)
    end

    def self.list_attributes_for_profile(profile)
      instance.list_attributes_for_profile(profile)
    end

    def initialize
      # this is a collection of profiles which have a value of attribute objects
      @list = {}

      # this is a list of optional profile name overrides set in the inspec.yml
      @profile_aliases = {}
    end

    def find_attribute(name, profile)
       profile = @profile_aliases[profile] if !profile_exist?(profile) && @profile_aliases[profile]
       raise Inspec::AttributeRegistryUnknownProfile, "Profile '#{profile}' does not have any attributes" unless profile_exist?(profile)
       raise Inspec::AttributeRegistryUnknownAttribute, "Profile '#{profile}' does not have a attribute with name '#{name}'" unless list[profile].key?(name)
       list[profile][name]
    end

    def register_attribute(name, profile, options = {})
      # check for a profile override name
      if profile_exist?(profile) && list[profile][name] && options.empty?
        list[profile][name]
      else
        list[profile] = {} unless profile_exist?(profile)
        list[profile][name] = Inspec::Attribute.new(name, options)
      end
    end

    def register_profile_alias(name, alias_name)
      @profile_aliases[name] = alias_name
    end

    def list_attributes_for_profile(profile)
      list[profile] = {} unless profile_exist?(profile)
      list[profile]
    end

    def __reset
      @list = {}
      @profile_aliases = {}
    end
  end
end
